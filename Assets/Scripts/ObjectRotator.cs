using UnityEngine;
using System.Collections;

namespace Wonnasmith
{
    public class ObjectRotator : MonoBehaviour
    {
        public Transform rotateObj;

        public float rotationSpeed = 0.2f;

        [System.Obsolete]
        void Update()
        {
            if (Input.GetMouseButton(0))
            {
                float XaxisRotation = Input.GetAxis("Mouse X") * rotationSpeed;
                float YaxisRotation = Input.GetAxis("Mouse Y") * rotationSpeed;
                // select the axis by which you want to rotate the GameObject
                rotateObj.RotateAround(Vector3.down, XaxisRotation);
                rotateObj.RotateAround(Vector3.right, YaxisRotation);
            }
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                rotateObj.RotateAround(Vector3.down, 0);
                rotateObj.RotateAround(Vector3.right, 0);
            }
        }
    }
}