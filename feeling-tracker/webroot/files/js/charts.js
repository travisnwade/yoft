document.addEventListener('DOMContentLoaded', function () {
    fetch('php/charts_data.php')  // Assume you have a PHP file that handles data retrieval
        .then(response => response.json())
        .then(data => {
            const emotions = data.map(entry => entry.emotion);
            const timestamps = data.map(entry => new Date(entry.timestamp).toLocaleDateString());

            const emotionCounts = emotions.reduce((acc, emotion) => {
                acc[emotion] = (acc[emotion] || 0) + 1;
                return acc;
            }, {});

            const ctx = document.getElementById('myChart').getContext('2d');
            const myChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: Object.keys(emotionCounts),
                    datasets: [{
                        label: '# of Entries',
                        data: Object.values(emotionCounts),
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.2)',
                            'rgba(54, 162, 235, 0.2)',
                            'rgba(255, 206, 86, 0.2)',
                            'rgba(75, 192, 192, 0.2)',
                            'rgba(153, 102, 255, 0.2)',
                            'rgba(255, 159, 64, 0.2)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)',
                            'rgba(153, 102, 255, 1)',
                            'rgba(255, 159, 64, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        });
});
