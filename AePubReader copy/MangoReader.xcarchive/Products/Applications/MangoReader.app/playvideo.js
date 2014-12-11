var handleVideos = function() {
    $('.youtube-video', body).each(function(idx, video) {
                                       $(video).attr('rel', '#reader-overlay');
                                       $(video).css('cursor', 'pointer');
                                       
                                       $(video).overlay({
                                                        onBeforeLoad: function() {
                                                        video_html = '<iframe class="youtube-player" type="text/html" width="600" height="380" src="http://www.youtube.com/embed/' + $(video).attr('alt') + '" frameborder="0"></iframe>';
                                                        var overlay = this.getOverlay().find('.wrap');;
                                                        overlay.html(video_html);
                                                        },
                                                        onBeforeClose: function() {
                                                        var overlay = this.getOverlay().find('.wrap');;
                                                        overlay.html("");
                                                        }
                                                        });
                                       });
    
}