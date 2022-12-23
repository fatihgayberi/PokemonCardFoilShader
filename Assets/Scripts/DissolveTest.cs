using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Wonnasmith
{
    public class DissolveTest : MonoBehaviour
    {
        [SerializeField] private DissolveController dissolveController;

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Alpha0))
            {
                if (dissolveController != null)
                {
                    dissolveController.DisolveWonna();
                }
            }
        }
    }
}