package org.denivip.osmf.plugins
{
	import org.denivip.osmf.elements.M3U8Loader;
	import org.denivip.osmf.events.HTTPHLSStreamingEvent;
	import org.osmf.elements.LoadFromDocumentElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.media.URLResource;
		
	public class HLSPluginInfo extends PluginInfo
	{
		
		public static var errorFunc:Function;
		
		public function HLSPluginInfo(items:Vector.<MediaFactoryItem>=null, elementCreationNotifFunc:Function=null){
			
			items = new Vector.<MediaFactoryItem>();
			items.push(
				new MediaFactoryItem(
					'org.denivip.osmf.plugins.HLSPlugin',
					canHandleResource,
					createMediaElement,
					MediaFactoryItemType.STANDARD
				)
			);
			
			super(items, elementCreationNotifFunc);
		}
		
		private function canHandleResource(resource:MediaResourceBase):Boolean{
            return M3U8Loader.canHandle(resource);
		}
		
		private var m3uLoader:M3U8Loader = null;
		
		private function createMediaElement():MediaElement{
			M3U8Loader.errorFunc = errorFunc;
			m3uLoader = new M3U8Loader();
			return new LoadFromDocumentElement(null, m3uLoader);
		}
	}
}
