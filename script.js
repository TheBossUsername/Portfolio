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