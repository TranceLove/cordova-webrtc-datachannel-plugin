
var VALID_TYPES = [
    "offer", "answer", "pranswer"
]

function RTCSessionDescription(sessionDescription)
{
    console.log(sessionDescription)
    this.type = sessionDescription.type;
    this.sdp = sessionDescription.sdp;
}

module.exports = RTCSessionDescription;
