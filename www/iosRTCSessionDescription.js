
var VALID_TYPES = [
    "offer", "answer", "pranswer"
]

function RTCSessionDescription(sessionDescription)
{
    this.type = sessionDescription.type;
    this.sdp = sessionDescription.sdp;
}

module.exports = RTCSessionDescription;
