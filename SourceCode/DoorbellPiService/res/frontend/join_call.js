const videoDiv = document.getElementById("video-div");

// Increases for each person that joins the call including the doorbell.
// Reaching one after someone leaves the call, indicates that the call should be left
var peopleRegisteredInCall = 0;  
var videoChatRoom = null;

// https://stackoverflow.com/questions/4842590/how-to-run-a-function-when-the-page-is-loaded
document.addEventListener('DOMContentLoaded', function() {
  videoChatRoom = async (roomName, token) => {
    // Join the video room with the Access Token and the given room name
    const room = await Twilio.Video.connect(token, {
      room: roomName,
    });
    return room;
  };

  // Render the local and remote participants' video and audio tracks
  handleConnectedParticipant(videoChatRoom.localParticipant);
  videoChatRoom.participants.forEach(handleConnectedParticipant);
  videoChatRoom.on("participantConnected", handleConnectedParticipant);

  // Handle cleanup when a participant disconnects
  room.on("participantDisconnected", handleDisconnectedParticipant);

  // Handle navigation that could occur, has the doorbell leave under different edge case situations. This also helps during testing.
  window.addEventListener("pagehide", () => room.disconnect());
  window.addEventListener("beforeunload", () => room.disconnect());
});

const handleConnectedParticipant = (participant) => {
  // Tracks the connected participant

  // Create a div for this participant's tracks
  const participantDiv = document.createElement("div");
  participantDiv.setAttribute("id", participant.identity);
  container.appendChild(participantDiv);

  // Iterate through the participant's published tracks and
  // call `handleTrackPublication` on them
  participant.tracks.forEach((trackPublication) => {
    handleTrackPublication(trackPublication, participant);
  });

  // Listen for any new track publications
  participant.on("trackPublished", handleTrackPublication);
};

const handleTrackPublication = (trackPublication, participant) => {
  function displayTrack(track) {
    // Append this track to the participant's div and render it on the page
    const participantDiv = document.getElementById(participant.identity);
    // track.attach creates an HTMLVideoElement or HTMLAudioElement
    // (depending on the type of track) and adds the video or audio stream
    participantDiv.append(track.attach());
  }

  // Check if the trackPublication contains a `track` attribute. If it does,
  // we are subscribed to this track. If not, we are not subscribed.
  if (trackPublication.track) {
    displayTrack(trackPublication.track);
  }

  // Listen for any new subscriptions to this track publication
  trackPublication.on("subscribed", displayTrack);
};

const handleDisconnectedParticipant = (participant) => {
  // Stop listening for this participant
  participant.removeAllListeners();

  // Remove this participant's div from the page
  const participantDiv = document.getElementById(participant.identity);
  participantDiv.remove();

  // Decide whether to disconnect from the video chat
  if (--peopleRegisteredInCall == 1) {
    disconnect(); // The doorbell is by itself in the call.
  }
};

const disconnect = () => {
  room.disconnect();
}