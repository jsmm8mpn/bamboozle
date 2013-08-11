var timerId;

function register(callback) {

    socket.emit('register', {
        hangoutId: hangoutId,
        userId: userId
    }, function(data) {
        if (result && result.start) {
            setupGame(result);
        }
        else {
           // startGameChecker();
        }

        if (callback) {
            callback(result);
        }
    });

    setInterval(function() {
        socket.emit('ping', {
            hangoutId:hangoutId,
            userId:userId
        });
    }, 10000);
}

function ready() {
    clearResults();

    socket.emit('ready', {
        hangoutId: hangoutId,
        userId: userId
    });

    //startGameChecker();
}

function newGame() {

    var timeLimit = 90;
    var timeLimitField = document.getElementById('timeLimit');
    if (timeLimitField) {
        timeLimit = timeLimitField.value;
    }

    var game = {
        hangoutId: hangoutId,
        userId: userId,
        timeLimit: timeLimit,
        minWordLength: 3
    };


    socket.emit('newGame', game);
}

/*
function startGameChecker() {
    var startGameChecker = setInterval(function() {
        get('game?hangoutId='+hangoutId, function(result) {
            if (result && result.start) {
                clearInterval(startGameChecker);
                setupGame(result);
            }
        });
    }, 1000);
}
*/

function setupGame(game) {
    startTimer(game.timeLeft, game.timeLimit);

    hide('startDiv')

    setTimeout(function() {
        get('letters?hangoutId='+hangoutId, function(letters) {
            populateBoard(letters);
            displayBoard();
            show('quitDiv');
        });
    }, (game.timeLeft - game.timeLimit)*1000);
}

function voteQuit() {
    hide('quitDiv');
    socket.emit('quit', {
        hangoutId: hangoutId,
        userId: userId
    });
}

function populateBoard(letters) {
    var board = document.getElementById('board');

    var table = '<table>';
    for (var y=0; y<letters.length; y++){
        table += "<tr>";
        for (var x=0; x<letters[y].length; x++){
            table += "<td>" + letters[y][x] + "</td>";
        }
        table += "</tr>";
    }
    table += '</table>';

    board.innerHTML = table;
}

function displayBoard() {
    hide('results');
    show('mainDiv');
    show('wordInput');
    document.getElementById('wordInput').focus();
}

function clearResults() {
    clear('board');
    clear('wordList');
    clear('wordResult');
    clear('results');
    clear('timer');
}

function startTimer(timeLeft, timeLimit) {
    show('timer');
    timerId = setInterval(function() {
        timeLeft = timeLeft - 1;

        if (timeLeft % 5 == 0) {
            get('time?hangoutId='+hangoutId, function(result) {
                if (result) {
                    timeLeft = result;
                }
                else {
                    timerExpired();
                }
            });
        }

        var secondsLeft = timeLeft;
        if (secondsLeft > timeLimit) {
            secondsLeft = secondsLeft - timeLimit;
        }
        else if (secondsLeft < 15) {
            document.getElementById('timer').className = 'timer-warn';
        }

        document.getElementById('timer').innerHTML = secondsLeft;
        if (secondsLeft == 0) {
            timerExpired();
        }

    }, 1000)
}

function timerExpired() {
    hide('quitDiv');
    hide('wordInput');
    clearInterval(timerId);

    getResults();
}

function submitWord(e) {
    if (e && e.keyCode == 13) {
        var word = document.getElementById('wordInput').value;

        var body = {
            hangoutId: hangoutId,
            userId: userId,
            word: word
        };

        socket.emit('word', body, function(result) {
            if (result.success) {
                document.getElementById('wordList').innerHTML += '<li>' + word + '</li>';
                document.getElementById('wordResult').innerHTML = 'word is valid';
            }
            else {
                document.getElementById('wordResult').innerHTML = result.error;
            }
        });
        document.getElementById('wordInput').value = '';
    }
}

function getResults() {
    get('results?hangoutId='+hangoutId, function(result) {
        writeResults(result);
    });
}

function writeResults(results) {
    var html = '';
    for (var userId in results) {
        var result = results[userId];
        var playerWords = result.words;
        playerWords.sort();

        html += '<div class="playerResult">';

        html += '<h1>'+userId+'</h1>'

        for (var wNum = 0; wNum < playerWords.length; wNum++) {
            var word = playerWords[wNum];
            if (result.scoredWords[word]) {
                html += '<li class="scored">' + word + '</li>';
            }
            else {
                html += '<li class="unscored">' + word + '</li>';
            }

        }
        html += '<div class="score">' + result.score + '</div>';

        html += '</div>';
    }

    document.getElementById('results').innerHTML = html;

    hide('mainDiv');
    show('results');
    show('startDiv');
}