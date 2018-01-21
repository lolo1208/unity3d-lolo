using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;


namespace ShibaInu
{
	/// <summary>
	/// 可以使 IPointerDownHandler, IPointerUpHandler, IPointerClickHandler 向上穿透一级
	/// </summary>
	[AddComponentMenu ("ShibaInu/Pointer Event Passer", 203)]
	[DisallowMultipleComponent]
	public class PointerEventPasser : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerClickHandler
	{
		
		[Tooltip ("是否可以穿透 Pointer Down")]
		public bool pointerDown = true;

		[Tooltip ("是否可以穿透 Pointer Up")]
		public bool pointerUp = true;

		[Tooltip ("是否可以穿透 Pointer Click")]
		public bool pointerClick = true;



		/// <summary>
		/// 向上穿透一级指定类型的事件
		/// </summary>
		/// <param name="eventData">Event data.</param>
		/// <param name="functor">Functor.</param>
		/// <typeparam name="T">The 1st type parameter.</typeparam>
		private void PassEvent<T> (PointerEventData eventData, ExecuteEvents.EventFunction<T> functor) where T : IEventSystemHandler
		{
			List<RaycastResult> results = new List<RaycastResult> ();
			EventSystem.current.RaycastAll (eventData, results);

			bool selfFounded = false;
			foreach (RaycastResult result in results) {
				if (result.gameObject == gameObject) {
					// 先找到自己
					selfFounded = true;

				} else if (selfFounded) {
					// 然后向上穿透一级
					GameObject go = ExecuteEvents.ExecuteHierarchy (result.gameObject, eventData, functor);
					if (go != null)
						break;
				}
			}
		}



		public void OnPointerDown (PointerEventData eventData)
		{
			if (pointerDown)
				PassEvent (eventData, ExecuteEvents.pointerDownHandler);
		}


		public void OnPointerUp (PointerEventData eventData)
		{
			if (pointerUp)
				PassEvent (eventData, ExecuteEvents.pointerUpHandler);
		}


		public void OnPointerClick (PointerEventData eventData)
		{
			if (pointerClick)
				PassEvent (eventData, ExecuteEvents.pointerClickHandler);
		}


		//
	}
}

