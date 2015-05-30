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

var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');

var _peerConnections = {};

function getRandomInt(min, max)
{
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

if(!window.plugin)
{
    window.plugin = {};
}

window.plugin.iosWebRTCPeerConnection = {
    signalingStateChanged: function(connectionID,state){
        console.log("Connection " + connectionID + " signalingStateChanged: " + state);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.signalingState = state;
            if(pc.onsignalingstatechange)
                pc.onsignalingstatechange(state);
        }
    },
    iceGatheringStateChanged: function(connectionID, state){
        console.log("Connection " + connectionID + " iceGatheringStateChanged: " + state);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.iceGatheringState = state;
        }
    },
    oniceconnectionstatechange: function(connectionID, state){
        console.log("Connection " + connectionID + " oniceconnectionstatechange: " + state);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.iceConnectionState = state;
            if(pc.oniceconnectionstatechange)
                pc.oniceconnectionstatechange(state);
        }
    },
    onicecandidate: function(connectionID, iceCandidateJson){
        console.log("Connection " + connectionID + " onicecandidate: " + iceCandidateJson);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            if(pc.onicecandidate)
                pc.onicecandidate({candidate:iceCandidateJson});
        }
    }
}

function RTCDataChannel(label, options)
{
	this.binaryType = "arraybuffer";
	this.bufferedAmount = 0;
	this.id = options.id || getRandomInt(0, 65535); //FIXME: unsafe
	this.label = label
	this.maxRetransmitTime = 65535
	this.maxRetransmits = 65535
	this.negotiated = options.negotiated || false;
	this.onclose = null;
	this.onerror = null;
	this.onmessage = null;
	this.onopen = null;
	this.ordered = options.ordered || true;
	this.protocol = options.protocol || "";
	this.readyState = "connecting";
	this.reliable = true;
}

RTCDataChannel.prototype.send = function(){

}

RTCDataChannel.prototype.close = function(){

}

function RTCPeerConnection(options)
{
    var self = this;

    this.iceConnectionState = "new"
    this.iceGatheringState = "new"
    this.localDescription = null
    this.onaddstream = null
    this.ondatachannel = null
    this.onicecandidate = null
    this.oniceconnectionstatechange = null
    this.onnegotiationneeded = null
    this.onremovestream = null
    this.onsignalingstatechange = null
    this.remoteDescription = null
    this.signalingState = "stable"

    exec(function(result){
        console.log(result)
        self.connectionID = result.connectionID;
        _peerConnections[result.connectionID] = self;
    }, function(err){
    	console.error(err);
    }, "iosWebRTCPlugin", "createRTCPeerConnection", [options]);
}

RTCPeerConnection.prototype.createDataChannel = function(label, options){

	var connectionID = this.connectionID;
	var retval = new RTCDataChannel(label, options);

	exec(function(result){
		console.log(result)
	}, function(err){
        console.error(err);
	}, "iosWebRTCPlugin", "createDataChannel", [connectionID, label, options]);

	return retval;
}

RTCPeerConnection.prototype.createOffer = function(callback){

	var connectionID = this.connectionID;

    exec(function(result){
        callback(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "createLocalOffer", [connectionID]);
}

RTCPeerConnection.prototype.createAnswer = function(callback){
    var connectionID = this.connectionID;

    exec(function(result){
        callback(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "createAnswer", [connectionID]);
}

RTCPeerConnection.prototype.setLocalDescription = function(sessionDescription, callback){
    console.log(sessionDescription)
    this.localDescription = sessionDescription;
    var connectionID = this.connectionID;

    exec(function(result){
        console.log(result)
        if(callback)
          callback();
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "setLocalOffer", [connectionID, sessionDescription]);
}

RTCPeerConnection.prototype.setRemoteDescription = function(sessionDescription, callback){
    this.remoteDescription = sessionDescription;
    var connectionID = this.connectionID;

    exec(function(result){
        console.log(result)
        if(callback)
          callback();
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "setRemoteOffer", [connectionID, sessionDescription]);
}

RTCPeerConnection.prototype.addIceCandidate = function(iceCandidate){
    var connectionID = this.connectionID;

    exec(function(result){
        console.log(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "addIceCandidate", [connectionID, iceCandidate]);

}

module.exports = RTCPeerConnection;
