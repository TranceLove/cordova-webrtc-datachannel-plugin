# cordova-webrtc-datachannel-plugin
Bindings to libWebRTC to enable WebRTC DataChannel support on iOS for Apache Cordova

## Introduction

This started off as a part of another bigger project, which requires WebRTC on mobile devices. However there is no support for WebRTC (yet) on iOS UIWebView, so I made this, and also as a little self-study for Objective-C on iOS.

It is not feature-complete, and it does has problems concerning handling unstable network conditions, so basically this is only a starting point.

As the time of writing, this plugin is able to setup a RTCDataChannel connection with signaling from Google's STUN server.

Feel free to fork for your own projects. I may not be able to look at here all the time, so you may choose not to send in pull requests, but just keep them in your repository.

## Prerequisites

As it is a little binding to `libWebRTC`, so first thing first you will need a compiled libjingle.

I use the build scripts from https://github.com/pristineio/webrtc-build-scripts to build the library. As the time of writing, my libWebRTC is at 9396.

Then pull the library, as well as libjingle's dependencies into your Cordova-based XCode project, and you are good to go.

## Usage

The Javascript library is designed to be as close to the original WebRTC Javascript API as possible, except they are prefixed with `ios`. However, because Cordova's calls from Javascript to native code are always asychronous, they require a callback function.

## TODO

This is more like a study project before calling it a production-grade library, it's certainly lack of many features that a full-stack WebRTC API should support, because I'd only implement features I need as I code. For audio/video conversation over WebRTC, you may find there are other libraries available on Github too.

Additional TODOs (though it is very unlikely they can be implemented soon)

 * Gracefully handle network instability
 * Sending messages between peers

## License

MIT.

````
/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2015 Raymond Lai (TranceLove) <airwave209gt@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
````
