
# mudd.one - Multimodal Ultrasound Data Distiller (phase 1)

![License](https://img.shields.io/github/license/vetcoders/mudd.one)
![Python Version](https://img.shields.io/badge/python-3.8%2B-blue)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey)
![FastAPI](https://img.shields.io/badge/FastAPI-0.68%2B-green)
![React](https://img.shields.io/badge/React-18-blue)
![Status](https://img.shields.io/badge/status-active-success)

> mudd.one is the first phase of the **mudd suite**, a comprehensive toolkit for processing, analyzing, measuring, and providing diagnostic suggestions for veterinary ultrasound imaging data. This phase focuses on video data analysis and preparation of ML training datasets.

## 🎯 Vision

mudd.one aims to streamline the process of ultrasound video data analysis and dataset preparation for machine learning applications. Our goal is to provide veterinary professionals and ML researchers with powerful, user-friendly tools for processing ultrasound imaging data.

## 🚀 Key Features

### Data Input & Processing
- **Multiple Format Support**
  - Video: mp4, mov, avi, wmv (ffmpeg compatible)
  - Medical Imaging: DICOM (single & multiframe)
  - Raw ultrasound data streams

### Intelligent ROI Detection
- **Automatic Cropping**
  - AI-powered ultrasound area detection
  - Depth scale recognition
  - Configurable confidence threshold (≥0.9 default)
- **Manual Adjustments**
  - Interactive canvas interface
  - Precision cropping tools
  - Real-time preview

### Advanced Processing Capabilities
- **Video Enhancement**
  - Resolution normalization
  - Grayscale optimization
  - Noise reduction
- **Filtering Suite**
  - Histogram equalization
  - Contrast adjustment
  - Adaptive thresholding
  - Edge detection (Canny)
  - Custom filter integration

### Segmentation & Annotation
- **Flexible Masking Tools**
  - Model-assisted segmentation
  - Manual annotation capabilities
  - Multiple label support
- **Export Options**
  - Custom dataset formats
  - Batch processing
  - Metadata preservation

## 🛠️ Technology Stack

### Backend Infrastructure
- **Core**: Python 3.8+
- **API Framework**: FastAPI
- **Image Processing**: OpenCV, scikit-image
- **Medical Imaging**: pydicom
- **ML Integration**: Custom model endpoints

### Frontend Architecture
- **Framework**: React 18 with Next.js
- **State Management**: React Hooks
- **UI Components**: Custom component library
- **Canvas Handling**: Custom WebGL renderer

### Development Tools
- **Version Control**: Git
- **Documentation**: OpenAPI/Swagger
- **Testing**: pytest, React Testing Library
- **Linting**: pylint, ESLint

## 📋 System Requirements

### Minimum Requirements
- CPU: 4 cores
- RAM: 8GB
- Storage: 20GB
- GPU: Optional

### Recommended Specifications
- CPU: 8+ cores
- RAM: 16GB+
- Storage: 50GB+ SSD
- GPU: CUDA/Metal compatible

### Software Prerequisites
- Python 3.8 or higher
- Node.js 16 or higher
- FFmpeg
- Git

## 🔧 Installation

### Quick Start
```bash
# Clone repository
git clone https://github.com/vetcoders/mudd.one.git
cd mudd.one

# Install dependencies
chmod +x install.sh
./install.sh
```

### Manual Installation
```bash
# Backend setup
cd server
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt

# Frontend setup
cd client
npm install
```

### Configuration
1. Copy environment template:
```bash
cp .env.example .env
```

2. Configure environment variables:
```env
NODE_ENV=development
API_URL=http://localhost:8000
MODEL_PATH=/path/to/model
```

## 🚦 Getting Started

### Running the Application
```bash
# Start backend server
python run.py

# In another terminal, start frontend
cd client
npm run dev
```

### Basic Usage Flow
1. Upload ultrasound video/DICOM
2. Review automatic cropping
3. Adjust if necessary
4. Apply processing filters
5. Create segmentation masks
6. Export processed data

## 📊 Project Architecture

```
mudd.one/
├── client/                     # Frontend Application
│   ├── src/
│   │   ├── components/         # React Components
│   │   │   ├── ui/            # Base UI Components
│   │   │   ├── upload/        # Upload Interface
│   │   │   ├── processing/    # Processing Tools
│   │   │   └── visualization/ # Results Display
│   │   ├── pages/             # Next.js Pages
│   │   └── styles/            # Global Styles
│   └── public/                # Static Assets
├── server/                    # Backend Application
│   ├── core/
│   │   ├── sm_integration/    # Segmentation Integration
│   │   ├── memory_bank/       # Memory Management
│   │   └── processors/        # Image Processing
│   ├── api/
│   │   ├── routes/            # API Endpoints
│   │   └── services/          # Business Logic
│   └── ml/
│       ├── models/            # ML Models
│       └── training/          # Training Utils
├── docs/                      # Documentation
└── installation/              # Install Scripts
```

## 🔌 API Reference

### Video Processing Endpoints

#### Upload Video
```http
POST /api/upload
```
Accepts video files for processing.

#### Process Video
```http
POST /api/process
```
Initiates video processing pipeline.

#### Apply Filter
```http
POST /api/apply-filter
```
Applies specified filter to frames.

#### Create Mask
```http
POST /api/create-mask
```
Generates segmentation mask.

## 🧪 Development Guide

### Backend Development
```bash
cd server
pip install -r requirements.txt
uvicorn app:app --reload
```

### Frontend Development
```bash
cd client
npm install
npm run dev
```

### Testing
```bash
# Backend tests
pytest

# Frontend tests
npm test
```

## 🤝 Contributing

We welcome contributions! See our [Contributing Guide](CONTRIBUTING.md) for details.

### Contribution Flow
1. Fork repository
2. Create feature branch (`git checkout -b feature/NewFeature`)
3. Commit changes (`git commit -m 'Add NewFeature'`)
4. Push to branch (`git push origin feature/NewFeature`)
5. Submit Pull Request

### Development Guidelines
- Follow Python (PEP 8) and JavaScript style guides
- Add tests for new features
- Update documentation as needed
- Maintain compatibility with existing features

## 🐛 Troubleshooting

### Common Issues

#### Segmentation Model Loading
```
Error: Could not load segmentation model
Solution: Verify model path and GPU compatibility
```

#### DICOM Processing
```
Error: Cannot read DICOM file
Solution: Check pydicom installation and file integrity
```

#### Memory Management
```
Error: Out of memory
Solution: Adjust batch size or reduce video resolution
```

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## 🌟 Credits

Developed and maintained by [hiai.vision®](https://hiai.vision) (the AMLT.ai brand)

## 📞 Support & Contact

### Technical Support
- GitHub Issues: [Issue Tracker](https://github.com/vetcoders/mudd.one/issues)
- Documentation: [Wiki](https://github.com/vetcoders/mudd.one/wiki)

### Contact Information
- Email: mudd.project@hiai.vision
- Website: [hiai.vision](https://hiai.vision)

## 🗺️ Roadmap

### Current Phase
- Core video processing functionality
- Basic segmentation tools
- Dataset export capabilities

### Future Development
- Advanced ML model integration
- Real-time processing
- Cloud deployment options
- Enhanced reporting features

### Version History
- v0.1.0 - Initial Release
  - Basic video processing
  - Manual cropping
  - Simple filters    **mudd.one** app is the first phase of the complex **mudd suite** focused on ultrasound video data analysis and preparation training datasets for various ML tools. It supports various video formats (ffmpeg compatibile) and DICOM files (single and multiframe) by pydicom implementation, providing automatic and manual cropping, frame extraction, preprocessing, filtering, and masking capabilities using user-prefered segmentation model.

## Features
- Multiple format support (mp4, mov, avi, wmv, DICOM multiframe)
- Automatic ultrasound area detection and cropping using simple binary detection or AI segmentation model of user's choice (start- and endpoints provided)
- Automatic cropping of ultrasound area with depth scale based on segmentation model confidence level (≥0.9 by default)
- Manual cropping with canvas tools upon failed to apply automatic crop
- Video preprocessing (resolution normalization, grayscale conversion)
- Various filtering options (histogram equalization, contrast adjustment, adaptive thresholding, canny and others)
- Manual masking and labeling canvas tool with basic segmentation libraries drawing function or advenced segmentation model of user's choice delivered canvas tool (implementation start- and endpoints provided)
- Customizable export formats tailored to user's ML dataset requirements
- FastAPI Backend and React/Node.js Frontend with basic UI demo provided

## Project Tree Structure
```
mudd.one/
├── client/                     # Frontend Application
│   ├── src/
│   │   ├── components/         # React Components
│   │   │   ├── ui/             # Reusable UI Components
│   │   │   │   ├── Button/     # Custom Button Components
│   │   │   │   ├── Input/      # Form Input Components
│   │   │   │   └── Layout/     # Layout Components
│   │   │   ├── upload/         # Image Upload Components
│   │   │   ├── processing/     # Image Processing Interface
│   │   │   └── visualization/  # Results Visualization
│   │   ├── pages/              # Next.js Pages
│   │   └── styles/             # Global Styles
│   └── public/                 # Static Assets
├── server/                     # Backend Application
│   ├── core/
│   │   ├── sm_integration/     # Segmentation model Integration
│   │   ├── memory_bank/        # Memory & Confidence System
│   │   └── processors/         # Image Processors
│   ├── api/
│   │   ├── routes/             # FastAPI Endpoints
│   │   └── services/           # Business Logic
│   └── ml/
│       ├── models/             # AI Models
│       └── training/           # Training Scripts
├── docs/                       # Documentation and dependencies list
└── installation/               # Platform dependend installation .sh scripts
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/vetcoders/mudd.one.git
cd mudd
```

2. Run the installation script:
```bash
chmod +x install.sh
./install.sh
```

3. Configure the environment:
- Copy `.env.example` to `.env`
- Adjust settings according to your environment

## Usage

1. Start the application:
```bash
python run.py
```

2. Open web browser and navigate to:
```
http://localhost:3000
```

3. Processing workflow:
   - Upload video/DICOM file
   - Verify automatic cropping or adjust manually
   - Review cropped video with cineloop scrolling tool
   - Apply filters as needed
   - Create masks 
   - Export processed data

## API Endpoints

### Backend API
- `POST /api/upload` - Upload video file
- `POST /api/process` - Process video
- `POST /api/apply-filter` - Apply filter to frame (noise detection dependend)
- `POST /api/create-mask` - Create mask using segmentation tool (as example)

## Development

### Backend Development
```bash
cd backend
pip install -r requirements.txt
uvicorn app:app --reload
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
```

## Troubleshooting

### Common Issues

1. SAM2.1 Model Loading
```
Error: Could not load SAM model
Solution: Ensure CUDA or MPS is properly installed and model checkpoint exists
```

2. DICOM Processing
```
Error: Cannot read DICOM file
Solution: Check if pydicom is properly installed and file is not corrupted
```

3. Memory Issues
```
Error: Out of memory
Solution: Reduce batch size or video resolution
```

## Contributing
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License
MIT License

## Contact
For support or questions, please contact: mudd.project@hiai.vision#
Multimodal Ultrasound Data Distiller by hiai.vision® (the AMLT.ai brand)
