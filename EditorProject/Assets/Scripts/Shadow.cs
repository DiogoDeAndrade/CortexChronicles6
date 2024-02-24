using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NaughtyAttributes;

public class Shadow : MonoBehaviour
{
    private Material material;

    [Button("Update Mesh")]
    private void UpdateMesh()
    {
       var path = GetComponent<OkapiKit.Path>();
        if (path)
        {
            var points = path.GetPoints();
            if (path.isLocalSpace)
            {
                for (int i = 0; i < points.Count; i++)
                {
                    var pt = points[i];

                    pt = transform.worldToLocalMatrix * new Vector4(pt.x, pt.y, pt.z, 1);

                    points[i] = pt;
                }
            }
            var mesh = CreateMeshFromPolygon(points);

            var meshFilter = GetComponent<MeshFilter>();
            if (meshFilter == null) meshFilter = gameObject.AddComponent<MeshFilter>();
            meshFilter.mesh = mesh;

            var meshRenderer = GetComponent<MeshRenderer>();
            if (meshRenderer == null) meshRenderer = gameObject.AddComponent<MeshRenderer>();
        }
    }

    // Function to convert a list of 2D points into a mesh
    public static Mesh CreateMeshFromPolygon(List<Vector3> points)
    {
        // Create a new mesh
        Mesh mesh = new Mesh();

        mesh.vertices = points.ToArray();

        // Triangulation (naive approach, only works properly for simple concave polygons without holes)
        List<int> triangles = new List<int>();
        int n = points.Count;
        for (int i = 0; i < n - 2; i++)
        {
            // Simple fan triangulation, not suitable for complex concave polygons
            triangles.Add(0);
            triangles.Add(i + 1);
            triangles.Add(i + 2);
        }

        mesh.triangles = triangles.ToArray();

        // Recalculate normals
        mesh.RecalculateNormals();

        return mesh;
    }
}
