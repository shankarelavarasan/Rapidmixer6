# Rapid Mixer Web Demo

A web-based audio mixing application that demonstrates the core functionality of Rapid Mixer.

## Features

- **Multi-track Audio Mixing**: Load and mix multiple audio files simultaneously
- **Real-time Controls**: Adjust volume, pan, reverb, and echo for each track
- **Visual Waveforms**: See audio waveform representations for each track
- **Master Controls**: Global volume control and playback management
- **Modern UI**: Beautiful, responsive interface with gradient backgrounds and smooth animations

## How to Use

1. **Open the Demo**: Open `index.html` in a modern web browser
2. **Load Audio Files**: Click the "📁 Load Audio" button on any track to upload an audio file
3. **Adjust Controls**: Use the sliders to control volume, pan, reverb, and echo for each track
4. **Play Audio**: Click the play button on individual tracks or use "Play All" for synchronized playback
5. **Master Volume**: Adjust the overall mix volume using the master volume control

## Supported Audio Formats

- MP3
- WAV
- OGG
- M4A
- And other formats supported by your browser

## Browser Compatibility

- Chrome (recommended)
- Firefox
- Safari
- Edge

## Technical Details

- Built with vanilla HTML, CSS, and JavaScript
- Uses Web Audio API for audio processing
- Responsive design works on desktop and mobile
- No external dependencies required

## Limitations

- Export functionality is placeholder (shows in UI but not implemented)
- Advanced effects are simulated in the UI
- Real-time waveform visualization is static

## Deployment

To deploy this web demo:

1. Upload the `index.html` file to any web server
2. Access via HTTP/HTTPS (file:// protocol may have limitations)
3. Ensure the server supports the required MIME types for audio files

## Future Enhancements

- Real-time waveform visualization
- Audio export functionality
- More advanced effects processing
- Cloud storage integration
- Collaborative mixing features