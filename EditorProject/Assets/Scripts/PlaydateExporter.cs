using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NaughtyAttributes;
using UnityEngine.Tilemaps;
using System.IO;
using System;
using static UnityEngine.EventSystems.EventTrigger;

public class PlaydateExporter : MonoBehaviour
{
    [SerializeField] private string     baseFilename = "Level01";
    [SerializeField] private Tilemap    tilemap;

    private Dictionary<Sprite, int> tilemapIndex;
    private List<Sprite>            tileSprites;

    [Button("Export")]
    void Export()
    {
        // Output tilemap
        ExportTilemap();
        // Export paths
        ExportPaths();
        // Export enemies
        ExportLevelData();
    }

    void ExportTilemap()
    {
        tilemapIndex = new Dictionary<Sprite, int>();
        tileSprites = new List<Sprite>();

        string  targetFilename = GetTargetFilename("tilemaps", "_tilemap.bin");
        var     bounds = tilemap.cellBounds;
        UInt32  sizeX = (UInt32)tilemap.size.x;
        UInt32  sizeY = (UInt32)tilemap.size.y;

        byte[]  data = new byte[sizeX * sizeY];
        int index = 0;
        for (int y = bounds.yMax - 1; y >= bounds.yMin; y--)
        {
            for (int x = bounds.xMin; x < bounds.xMax; x++)
            {
                byte tile = GetTileIndex(x, y);

                data[index] = tile;
                index++;
            }
        }

        // Check how big is the images
        int     tsx = (int)tileSprites[0].rect.width;
        int     tsy = (int)tileSprites[0].rect.height;
        var     origin = -bounds.min;

        using (FileStream fileStream = new FileStream(targetFilename, FileMode.Create))
        using (BinaryWriter writer = new BinaryWriter(fileStream))
        {
            // Write the two 32-bit unsigned integers
            writer.Write(sizeX);
            writer.Write(sizeY);
            writer.Write((UInt32)tsx);
            writer.Write((UInt32)tsy);
            writer.Write((UInt32)(-bounds.min.x * tsx));
            writer.Write((UInt32)(bounds.max.y * tsy));

            // Write the additional byte array data
            writer.Write(data);
        }

        // Create tilemap
        int dim = Mathf.CeilToInt(Mathf.Sqrt(tileSprites.Count));

        var     tileset = new Texture2D(dim * tsx, dim * tsy, TextureFormat.ARGB32, false);
        Color[] clearColors = new Color[dim * tsx * dim * tsy];
        for (int i = 0; i < clearColors.Length; i++)
        {
            clearColors[i] = Color.clear;
        }
        tileset.SetPixels(clearColors);
        tileset.Apply();

        for (int i = 0; i < tileSprites.Count; i++)
        {
            // Calculate the position of this sprite in the atlas
            int x = (i % dim) * tsx;
            int y = (dim - 1 - (i / dim)) * tsy;

            // Get the sprite's texture and its pixel data
            Sprite sprite = tileSprites[i];
            Texture2D spriteTexture = sprite.texture;
            Color[] pixels = spriteTexture.GetPixels((int)sprite.textureRect.x, (int)sprite.textureRect.y, tsx, tsy);

            // Set the pixels in the correct position in the atlas
            tileset.SetPixels(x, y, tsx, tsy, pixels);
        }

        // Apply all changes to the atlas texture
        tileset.Apply();

        targetFilename = GetTargetFilename("tilemaps", $"-table-{tsx}-{tsy}.png");

        File.WriteAllBytes(targetFilename, tileset.EncodeToPNG());
    }

    byte GetTileIndex(int x, int y)
    {
        var pos = new Vector3Int(x, y, 0);
        var tile = tilemap.GetTile<Tile>(pos);

        if (tile == null)
        {
            return 0;
        }

        // Check if this tile was already used
        if (tilemapIndex.TryGetValue(tile.sprite, out var ret))
        {
            return (byte)ret;
        }

        tileSprites.Add(tile.sprite);
        tilemapIndex.Add(tile.sprite, tileSprites.Count);

        return (byte)tileSprites.Count;
    }

    string GetTargetFilename(string folder, string postfix)
    {
        string ret = Path.Combine(Application.dataPath, $"../../PlaydateProject/source/{folder}");
        ret = Path.Combine(ret, $"{baseFilename}{postfix}");

        return ret;
    }

    void ExportPaths()
    {
        var paths = FindObjectsOfType<OkapiKit.Path>();

        string targetFilename = GetTargetFilename("paths", "_paths.bin");

        using (FileStream fileStream = new FileStream(targetFilename, FileMode.Create))
        using (BinaryWriter writer = new BinaryWriter(fileStream))
        {
            // Write the two 32-bit unsigned integers
            writer.Write((UInt32)paths.Length);

            foreach (var path in paths)
            {
                ExportPath(writer, path);
            }
        }
    }

    void ExportPath(BinaryWriter writer, OkapiKit.Path path)
    {
        var points = path.GetPoints();

        var pathName = System.Text.Encoding.ASCII.GetBytes(path.gameObject.name);
        writer.Write((UInt32)pathName.Length);
        writer.Write(pathName);
        writer.Write((UInt32)((path.isClosed) ? (1) : (0)));
        writer.Write(points.Count);
        foreach (var pt in points)
        {
            writer.Write(pt.x);
            writer.Write(pt.y);
        }
    }

    void ExportLevelData()
    {
        string targetFilename = GetTargetFilename("levels", ".bin");

        using (FileStream fileStream = new FileStream(targetFilename, FileMode.Create))
        using (BinaryWriter writer = new BinaryWriter(fileStream))
        {
            var enemies = FindObjectsOfType<Enemy>();
            writer.Write((UInt32)enemies.Length);

            foreach (var enemy in enemies)
            {
                ExportEnemy(writer, enemy);
            }

            var turrets = FindObjectsOfType<Turret>();
            writer.Write((UInt32)turrets.Length);

            foreach (var turret in turrets )
            {
                ExportTurret(writer, turret);
            }

            var doors = FindObjectsOfType<Door>();
            writer.Write((UInt32)doors.Length);

            foreach (var door in doors)
            {
                ExportDoor(writer, door);
            }
        }
    }


    void ExportEnemy(BinaryWriter writer, Enemy enemy)
    {
        var enemyName = System.Text.Encoding.ASCII.GetBytes(enemy.gameObject.name);
        var pathName = System.Text.Encoding.ASCII.GetBytes(enemy.path.gameObject.name);
        writer.Write((UInt32)enemyName.Length);
        writer.Write(enemyName);
        writer.Write((UInt32)pathName.Length);
        writer.Write(pathName);
        writer.Write(enemy.speed);
        writer.Write(enemy.difficulty);
        writer.Write((UInt32)enemy.keyId);
    }

    void ExportTurret(BinaryWriter writer, Turret turret)
    {
        var turretName = System.Text.Encoding.ASCII.GetBytes(turret.gameObject.name);
        writer.Write((UInt32)turretName.Length);
        writer.Write(turretName);
        writer.Write(turret.transform.position.x);
        writer.Write(turret.transform.position.y);
        writer.Write(turret.transform.rotation.eulerAngles.z);
        writer.Write(turret.scanDuration);
        writer.Write(turret.scanPause);
        writer.Write(turret.scanAngularRange);
        writer.Write(turret.difficulty);
    }

    void ExportDoor(BinaryWriter writer, Door door)
    {
        var nextLevel = System.Text.Encoding.ASCII.GetBytes(door.nextLevel);
        writer.Write(door.transform.position.x);
        writer.Write(door.transform.position.y);
        writer.Write(door.radius);
        writer.Write((UInt32)((door.isFinalExit)?(1):(0)));
        writer.Write((UInt32)nextLevel.Length);
        writer.Write(nextLevel);
        writer.Write((UInt32)door.requiredKey);
    }
}
