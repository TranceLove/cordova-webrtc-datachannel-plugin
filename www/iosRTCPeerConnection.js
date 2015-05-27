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
                pc.onsignalingstatechange(/*?*/state);
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
                pc.oniceconnectionstatechange(/*?*/state);
        }
    },
    onicecandidate: function(connectionID, iceCandidateJson){
        console.log("Connection " + connectionID + " onicecandidate: " + iceCandidateJson);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            if(pc.onicecandidate)
                pc.onicecandidate(iceCandidateJson);
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

RTCPeerConnection.prototype.setLocalDescription = function(sessionDescription){
    console.log(sessionDescription)
    this.localDescription = sessionDescription;
    var connectionID = this.connectionID;

    exec(function(result){
        console.log(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "setLocalOffer", [connectionID, sessionDescription]);
}

RTCPeerConnection.prototype.setRemoteDescription = function(sessionDescription){
    this.remoteDescription = sessionDescription;
    var connectionID = this.connectionID;

    exec(function(result){
        console.log(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "setRemoteOffer", [connectionID, sessionDescription]);
}

RTCPeerConnection.prototype.addIceCandidate = function(iceCandidate){

}

module.exports = RTCPeerConnection;
