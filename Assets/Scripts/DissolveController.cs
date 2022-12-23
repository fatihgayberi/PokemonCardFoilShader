using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Wonnasmith
{
    public class DissolveController : MonoBehaviour
    {
        [SerializeField] private Material material;
        [SerializeField] private float duration;

        private Coroutine _dissolveCoroutine;

        private float _currentAmount;
        private float _elapsedTime = 0;

        bool isDissolve = true;

        private const string strAmount = "_Amount";

        public void DissolveReset()
        {
            if (material == null)
            {
                return;
            }

            if (_dissolveCoroutine != null)
            {
                StopCoroutine(_dissolveCoroutine);
            }

            _elapsedTime = 0;

            _dissolveCoroutine = StartCoroutine(IenumeratorDissolveReset());
        }

        public void DisolveWonna()
        {
            if (isDissolve)
            {
                Dissolve();
            }
            else
            {
                DissolveReset();
            }

            isDissolve = !isDissolve;
        }


        public void Dissolve()
        {
            if (material == null)
            {
                return;
            }

            if (_dissolveCoroutine != null)
            {
                StopCoroutine(_dissolveCoroutine);
            }

            _elapsedTime = 0;

            _dissolveCoroutine = StartCoroutine(IenumeratorDissolve());
        }


        private IEnumerator IenumeratorDissolve()
        {
            while (_elapsedTime < duration)
            {
                _currentAmount = Mathf.Lerp(1, 0, _elapsedTime / duration);

                _elapsedTime += Time.deltaTime;

                material.SetFloat(strAmount, _currentAmount);

                yield return null;
            }
        }

        private IEnumerator IenumeratorDissolveReset()
        {
            while (_elapsedTime < duration)
            {
                _currentAmount = Mathf.Lerp(0, 1, _elapsedTime / duration);

                _elapsedTime += Time.deltaTime;

                material.SetFloat(strAmount, _currentAmount);

                yield return null;
            }
        }
    }
}