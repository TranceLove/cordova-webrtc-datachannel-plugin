var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');

var _peerConnections = {};

function RTCPeerConnection(options)
{
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

    exec(function(){}, function(){}, "iosWebRTCPlugin", "createRTCPeerConnection", [options]);
}

RTCPeerConnection.prototype.createDataChannel = function(label, options){

}

RTCPeerConnection.prototype.createOffer = function(callback){

}

RTCPeerConnection.prototype.createAnswer = function(callback){

}

RTCPeerConnection.prototype.setLocalDescription = function(sessionDescription){
    this.localDescription = sessionDescription;
}

RTCPeerConnection.prototype.setRemoteDescription = function(sessionDescription){
    this.remoteDescription = sessionDescription;
}

RTCPeerConnection.prototype.addIceCandidate = function(iceCandidate){

}

module.exports = RTCPeerConnection;
