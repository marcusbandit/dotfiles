import QtQuick

// Utility component for animation helpers
Item {
    id: root
    
    // Exponential smoothing animation helper
    // Returns the smoothing factor for given speed and dt
    function smoothingFactor(speed, dt) {
        return 1 - Math.exp(-speed * dt);
    }
    
    // Apply exponential smoothing to a value
    function smoothValue(current, target, speed, dt) {
        let factor = smoothingFactor(speed, dt);
        return current + (target - current) * factor;
    }
}
