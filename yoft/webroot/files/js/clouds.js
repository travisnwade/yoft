document.addEventListener('DOMContentLoaded', function () {
    // Array of background images
    const backgrounds = [
        'url("media/clouds/bg0.jpg")',
        'url("media/clouds/bg1.jpg")',
        'url("media/clouds/bg2.jpg")',
        'url("media/clouds/bg3.jpg")',
        'url("media/clouds/bg4.jpg")',
        'url("media/clouds/bg5.jpg")',
        'url("media/clouds/bg6.jpg")',
        'url("media/clouds/bg7.jpg")',
        'url("media/clouds/bg8.jpg")',
        'url("media/clouds/bg9.jpg")',
        'url("media/clouds/bg10.jpg")',
        'url("media/clouds/bg11.jpg")',
        'url("media/clouds/bg12.jpg")',
        'url("media/clouds/bg13.jpg")',
        'url("media/clouds/bg14.jpg")',
        'url("media/clouds/bg15.jpg")',
        'url("media/clouds/bg16.jpg")',
        'url("media/clouds/bg17.jpg")',
        'url("media/clouds/bg18.jpg")',
        'url("media/clouds/bg19.jpg")',
        'url("media/clouds/bg20.jpg")',
        'url("media/clouds/bg21.jpg")',
        'url("media/clouds/bg22.jpg")',
        'url("media/clouds/bg23.jpg")'
        ];

    // Select a random background
    const randomBackground = backgrounds[Math.floor(Math.random() * backgrounds.length)];

    // Apply the random background to the body
    document.body.style.backgroundImage = randomBackground;
});


document.addEventListener('DOMContentLoaded', function () {
    const textArea = document.getElementById('emotion-text');
    const charCount = document.getElementById('char-count');
    const buttons = document.querySelectorAll('.emotion-buttons button');
    let selectedEmotion = '';

    // Character count update
    textArea.addEventListener('input', () => {
        const remaining = 400 - textArea.value.length;
        charCount.textContent = `${remaining} characters remaining`;
    });

    // Emotion button selection
    buttons.forEach(button => {
        button.addEventListener('click', () => {
            buttons.forEach(btn => btn.classList.remove('selected'));
            button.classList.add('selected');
            selectedEmotion = button.getAttribute('data-emotion');
        });
    });

    // Submit button click handler
    document.getElementById('submit-button').addEventListener('click', () => {
        const text = textArea.value;
        if (text && selectedEmotion) {
            const formData = new FormData();
            formData.append('emotion', selectedEmotion);
            formData.append('text', text);
    
            fetch('php/submissions.php', {  // Updated path to submissions.php
                method: 'POST',
                body: formData,
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    loadHistory();
                    textArea.value = '';
                    charCount.textContent = '400 characters remaining';
                    buttons.forEach(btn => btn.classList.remove('selected'));
                    selectedEmotion = '';
                }
            });
        } else {
            alert('Please enter some text and select an emotion.');
        }
    });

    // Mobile-specific behavior
    if ('ontouchstart' in window || navigator.maxTouchPoints) {
        document.querySelectorAll('.emotion-buttons button i').forEach(icon => {
            icon.style.display = 'none';
        });
        document.querySelectorAll('.emotion-buttons button .text').forEach(text => {
            text.style.display = 'inline';
        });
    }

    // Load submission history
    loadHistory();
});

function loadHistory() {
    fetch('php/submissions.php')  // Updated path to submissions.php
        .then(response => response.json())
        .then(data => {
            const historyDiv = document.getElementById('history');
            historyDiv.innerHTML = '';
            data.forEach(entry => {
                const newEntryDiv = document.createElement('div');
                newEntryDiv.classList.add('entry');

                const timestampDiv = document.createElement('div');
                timestampDiv.classList.add('timestamp');
                timestampDiv.innerText = new Date(entry.timestamp).toLocaleString();

                const textDiv = document.createElement('div');
                textDiv.classList.add('text');
                textDiv.innerText = entry.text;

                const emotionDiv = document.createElement('div');
                emotionDiv.classList.add('emotion', entry.emotion);
                emotionDiv.innerText = entry.emotion.charAt(0).toUpperCase() + entry.emotion.slice(1);

                newEntryDiv.appendChild(timestampDiv);
                newEntryDiv.appendChild(textDiv);
                newEntryDiv.appendChild(emotionDiv);

                historyDiv.appendChild(newEntryDiv);
            });
        });        
}

document.addEventListener('DOMContentLoaded', function () {
    const menuButton = document.getElementById('menu-button');
    const menuModal = document.getElementById('menu-modal');

    menuButton.addEventListener('click', function () {
        if (menuModal.style.display === 'block') {
            menuModal.style.display = 'none';
        } else {
            menuModal.style.display = 'block';
        }
    });

    // Close the menu if clicked outside of it
    document.addEventListener('click', function (event) {
        if (!menuButton.contains(event.target) && !menuModal.contains(event.target)) {
            menuModal.style.display = 'none';
        }
    });
});
