var state_;
var metadata_;
var participants_;
var hangoutId;
var userId;

var firstPlayer = false;

function updateLocalParticipantsData(participants) {
    participants_ = participants;
}

function stateChanged(event) {
    console.log('state changed. updating...');
    state_ = event.state;
    metadata_ = event.metadata;

    var addedKeys = event.addedKeys;

    for (var i = 0; i < addedKeys.length; i++) {
        var added = addedKeys[i];
        console.log('added to state: ' + added.key);
        if (added.key == 'game') {
            var game = JSON.parse(added.value);
            startTimer(game.start, game.timeLimit);
        }
        else if (added.key == 'letters') {
            var letters = JSON.parse(added.value);
            populateBoard(letters);
            displayBoard();
        }
    }
}

function submitDelta(delta) {
    for (var key in delta) {
        if (typeof delta[key] === 'object') {
            delta[key] = JSON.stringify(delta[key]);
        }
    }

    gapi.hangout.data.submitDelta(delta);
}

function init() {
    if (gapi && gapi.hangout) {

        console.log('app is loading');

        var initHangout = function(apiInitEvent) {
            if (apiInitEvent.isApiReady) {
                console.log('initializing');

                gapi.hangout.data.onStateChanged.add(stateChanged);
                gapi.hangout.onParticipantsChanged.add(function(partChangeEvent) {
                    updateLocalParticipantsData(partChangeEvent.participants);
                });

                if (!state_) {
                    var state = gapi.hangout.data.getState();
                    var metadata = gapi.hangout.data.getStateMetadata();
                    if (state && metadata) {
                        state_ = state;
                        metadata_ = metadata;
                    }
                }
                if (!participants_) {
                    var initParticipants = gapi.hangout.getParticipants();
                    if (initParticipants) {
                        updateLocalParticipantsData(initParticipants);
                    }
                    document.getElementById('startDiv').style.display = 'block';
                }

                hangoutId = gapi.hangout.getHangoutId();
                userId = gapi.hangout.getLocalParticipantId();

                var socket = io.connect('https://bamboozle-zarala.rhcloud.com:8000');
                socket.on('game', setupGame);
                register();

                gapi.hangout.onApiReady.remove(initHangout);

            }
        };

        //document.addEventListener('timerExpired', gameEnd);

        gapi.hangout.onApiReady.add(initHangout);
    }
}
