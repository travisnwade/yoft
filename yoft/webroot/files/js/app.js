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
    const slideInMenu = document.getElementById('slide-in-menu');

    menuButton.addEventListener('click', function () {
        slideInMenu.classList.toggle('open');
    });

    // Close the menu if clicked outside of it
    document.addEventListener('click', function (event) {
        if (!menuButton.contains(event.target) && !slideInMenu.contains(event.target)) {
            slideInMenu.classList.remove('open');
        }
    });
});


document.addEventListener('DOMContentLoaded', () => {
    const filterButton = document.getElementById('filter-button');

    // Attach event listener to the filter button
    filterButton.addEventListener('click', () => {
        // Get the selected filter values
        const startDate = document.getElementById('start-date').value;
        const endDate = document.getElementById('end-date').value;
        const emotion = document.getElementById('emotion').value;
        const sortOrder = document.getElementById('sort-order').value;
        const groupBy = document.getElementById('group-by').value;

        // Create filter object to send to the backend
        const filterData = {
            startDate,
            endDate,
            emotion,
            sortOrder,
            groupBy
        };

        // Send the filter data to the backend via fetch
        fetch('php/filters_data.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(filterData)
        })
        .then(response => response.json())
        .then(data => {
            // Sort data based on the selected sort order
            if (sortOrder === 'newest') {
                data.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
            } else if (sortOrder === 'oldest') {
                data.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
            }

            // Clear the existing table body
            const tableBody = document.querySelector('#results-table tbody');
            tableBody.innerHTML = '';

            // Group the data if grouping is selected
            if (groupBy === 'emotion') {
                data = groupByField(data, 'emotion');
            } else if (groupBy === 'day-of-week') {
                data = groupByField(data, 'dayOfWeek');
            }

            // Populate the table with filtered results
            data.forEach(entry => {
                if (entry.isGroupHeader) {
                    // Create a header row for the group
                    const headerRow = document.createElement('tr');
                    const headerCell = document.createElement('td');
                    headerCell.colSpan = 3; // Span across all columns
                    headerCell.classList.add('group-header');
                    headerCell.textContent = capitalizeFirstLetter(entry.groupName);
                    headerRow.appendChild(headerCell);
                    tableBody.appendChild(headerRow);
                } else {
                    // Create a row for each result
                    const row = document.createElement('tr');
                    
                    // Create emotion, date, and collapsible text cell
                    const emotionCell = document.createElement('td');
                    const dateCell = document.createElement('td');
                    const detailsCell = document.createElement('td');

                    // Set the emotion content and add corresponding class for coloring
                    emotionCell.textContent = entry.emotion;
                    emotionCell.classList.add(entry.emotion); // Add class to match emotion name

                    // Format the date and day of the week
                    const date = new Date(entry.timestamp);
                    const formattedDate = date.toLocaleDateString(); // Format the date
                    const dayOfWeek = date.toLocaleDateString('en-US', { weekday: 'long' }); // Get day of the week

                    // Display the date with the day of the week underneath
                    dateCell.innerHTML = `${formattedDate}<br><span class="day-of-week">${dayOfWeek}</span>`;

                    // Create collapsible/expandable box for details
                    const detailsBox = document.createElement('div');
                    detailsBox.classList.add('details-box');
                    detailsBox.innerHTML = `<button class="expand-collapse">Show/Hide Details</button><div class="details-content">${entry.text}</div>`;
                    
                    // Append the cells to the row
                    detailsCell.appendChild(detailsBox);
                    row.appendChild(emotionCell);
                    row.appendChild(dateCell);
                    row.appendChild(detailsCell);

                    // Append the row to the table
                    tableBody.appendChild(row);

                    // Add expand/collapse functionality
                    const button = detailsBox.querySelector('.expand-collapse');
                    const content = detailsBox.querySelector('.details-content');

                    button.addEventListener('click', () => {
                        // Toggle the expanded class to show/hide the content
                        content.classList.toggle('expanded');
                    });
                }
            });
        })
        .catch(error => console.error('Error fetching filter data:', error));
    });
});

// Helper function to group data by a specific field
function groupByField(data, field) {
    const grouped = {};
    data.forEach(item => {
        const key = field === 'dayOfWeek' 
            ? new Date(item.timestamp).toLocaleDateString('en-US', { weekday: 'long' }) 
            : item[field];

        if (!grouped[key]) {
            grouped[key] = [];
        }
        grouped[key].push(item);
    });

    // Remove empty groups (where grouped[key].length is 0)
    const filteredGroups = Object.keys(grouped).filter(key => grouped[key].length > 0);

    // Flatten the grouped data back into a single array with headers
    return filteredGroups.reduce((acc, key) => {
        const groupHeader = { isGroupHeader: true, groupName: key };
        return [...acc, groupHeader, ...grouped[key]];
    }, []);
}

// Helper function to capitalize the first letter of a string
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}