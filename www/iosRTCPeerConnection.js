var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');

var _peerConnections = {};

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
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.iceGatheringState = state;
        }
    },
    oniceconnectionstatechange: function(connectionID, state){
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.iceConnectionState = state;
            if(pc.oniceconnectionstatechange)
                pc.oniceconnectionstatechange(/*?*/state);
        }
    },
    onicecandidate: function(connectionID, iceCandidateJson){
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            if(pc.onicecandidate)
                pc.onicecandidate(iceCandidateJson);
        }
    }
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
        console.log(result);
        self.connectionID = result.connectionID;
        _peerConnections[connectionID] = self;
    }, function(){}, "iosWebRTCPlugin", "createRTCPeerConnection", [options]);
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
