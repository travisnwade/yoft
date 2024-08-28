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