using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    public OkapiKit.Path  path;
    public float          speed = 4.0f;
    public float          difficulty = 1.0f;
    public int            keyId = 0;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnValidate()
    {
        if (path)
        {
            transform.position = path.GetPoints()[0];
        }
    }
}
