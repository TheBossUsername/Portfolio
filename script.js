const box = document.getElementById('edgeGlowBox');

box.addEventListener('mousemove', (e) => {
    const rect = box.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    // 1. Send exact coordinates for the flashlight spotlight
    box.style.setProperty('--mouse-x', `${x}px`);
    box.style.setProperty('--mouse-y', `${y}px`);

    // 2. Calculate edge proximity (60px threshold)
    const threshold = 60;
    
    // Math.max ensures the value never drops below 0 when the mouse is far away
    const glowLeft = Math.max(0, 1 - (x / threshold));
    const glowRight = Math.max(0, 1 - ((rect.width - x) / threshold));
    const glowTop = Math.max(0, 1 - (y / threshold));
    const glowBottom = Math.max(0, 1 - ((rect.height - y) / threshold));

    // 3. Send the intensities to CSS
    box.style.setProperty('--edge-left', glowLeft);
    box.style.setProperty('--edge-right', glowRight);
    box.style.setProperty('--edge-top', glowTop);
    box.style.setProperty('--edge-bottom', glowBottom);
});