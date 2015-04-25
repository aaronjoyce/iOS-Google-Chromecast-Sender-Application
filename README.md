Application Document

Google Chromecast 
This is currently operational for SoundCloud media. It is non-operational for YouTube media, as the Google Chromecast default received play is incompatible with such media (despite having passed a valid YouTube URI to the default Chromecast receiver application and the correct mimetype (“video/mp4”), it has failed to work).

I have used an AVPlayerViewController for the on-iOS-device playback. This player does not allow the playback of YouTube media. However, by adding the MPVolumeView instance, configured within the method ‘configurePlayerVolumeController’, to the YouTube player view (part of the YouTube API (YTPlayerView)) as a subview, AirPlay playback of YouTube media will work. For this to work with Google Chromecast, a custom receiver player must be built, and the appropriate Chromecast button view must, too, be added as a subview of the YouTube player view instance.

Additionally, you will see that a number of parameters must passed to the ‘ChromeCastDeviceController’ instance’s ‘loadMedia’ method in order to successfully play a media item on the external receiver device.

Once a media item has been successfully transmitted, playback control (i.e., play/pause, time interval, and volume control) is determined by the rate of the AVPlayer instance’s currently playing item. For this, observers have been configured to monitor on-iOS-device rate playback and system volume, and appropriate signals are sent to the receiver Chromecast device, by invoking its play/pause, time interval, and volume control utilities. iOS device volume is also ‘observer’, and changes to this are communicated back to the received iOS application. Additionally, within the ‘DeviceListTableViewController’ instance, the volume of a connected Chromecast device may be controlled, this time using a UISlider instance, that represents the external device’s volume, and such changes are ‘communicated back’ to the connected receiver Chromecast device.
