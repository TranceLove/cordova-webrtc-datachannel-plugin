
function RTCIceCandidate(iceCandidateJson)
{
    this.candidate = iceCandidateJson.candidate;
    this.sdpMid = iceCandidateJson.sdpMid;
	this.sdpMLineIndex = sdpMLineIndex;
}

module.exports = RTCIceCandidate;
