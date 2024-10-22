document.addEventListener('DOMContentLoaded', () => {
    const filterButton = document.getElementById('filter-button');

    // Attach event listener to the filter button
    filterButton.addEventListener('click', () => {
        // Get the selected filter values
        const startDate = document.getElementById('start-date').value;
        const endDate = document.getElementById('end-date').value;
        const emotion = document.getElementById('emotion').value;
        const dayOfWeek = document.getElementById('day-of-week').value;
        const month = document.getElementById('month').value;

        // Create filter object to send to the backend
        const filterData = {
            startDate,
            endDate,
            emotion,
            dayOfWeek,
            month
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
            // Sort data by timestamp (newest first)
            data.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

            // Clear the existing table body
            const tableBody = document.querySelector('#results-table tbody');
            tableBody.innerHTML = '';

            // Populate the table with filtered results
            data.forEach(entry => {
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
            });
        })
        .catch(error => console.error('Error fetching filter data:', error));
    });
});
