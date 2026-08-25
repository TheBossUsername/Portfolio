// 1. Grab EVERY monitor screen on the page using its class
const screens = document.querySelectorAll('.monitor-screen');

// 2. Loop through each individual screen
screens.forEach((box) => {
    
    box.addEventListener('mousemove', (e) => {
        // Calculate the mouse coordinates relative to the SPECIFIC box you are hovering
        const rect = box.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        // Send those coordinates to the CSS of that specific box
        box.style.setProperty('--mouse-x', `${x}px`);
        box.style.setProperty('--mouse-y', `${y}px`);
    });
    
});

/* --- EMAIL CLICK-TO-COPY LOGIC --- */
const emailMonitor = document.getElementById('email-monitor');
const emailTitle = document.getElementById('email-title');
const emailAddress = document.getElementById('email-address');

if (emailMonitor) {
    emailMonitor.addEventListener('click', () => {
        // 1. Write the email to the clipboard
        navigator.clipboard.writeText('brenden.scott.it@outlook.com').then(() => {
            
            // 2. Temporarily change the text
            const originalTitle = emailTitle.innerText;
            const originalAddress = emailAddress.innerText;
            
            emailTitle.innerText = 'Copied!';
            emailAddress.innerText = 'Saved to clipboard.';
            
            // Optional: Flash the text a success color (like a bright green)
            emailTitle.style.color = '#10b981'; 

            // 3. Reset everything back to normal after 2 seconds (2000 milliseconds)
            setTimeout(() => {
                emailTitle.innerText = originalTitle;
                emailAddress.innerText = originalAddress;
                emailTitle.style.color = ''; // Resets back to your CSS Azure Blue
            }, 2000);
            
        }).catch(err => {
            console.error('Failed to copy text: ', err);
        });
    });
}

const counterElement = document.getElementById('visitor-counter');

if (counterElement) {
    const apiUrl = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
        ? 'http://localhost:7071/api/GetCounter'
        : '/api/GetCounter';

    // 1. Check the browser's temporary session storage
    const cachedCount = sessionStorage.getItem('portfolioVisitorCount');

    if (cachedCount) {
        // 2. They already loaded this tab, show the cached number
        counterElement.innerText = cachedCount;
    } else {
        // 3. Brand new session! Call Azure.
        fetch(apiUrl)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                counterElement.innerText = data.count;
                // Save it to the temporary session
                sessionStorage.setItem('portfolioVisitorCount', data.count);
            })
            .catch(error => {
                console.error('Error fetching visitor count:', error);
                counterElement.innerText = 'N/A';
            });
    }
}