#!/usr/bin/env python3
"""
YOLOv8 to CoreML Conversion Script
-----------------------------------
This script converts YOLOv8s model to CoreML format for iOS deployment.

Requirements:
    pip install ultralytics coremltools

Usage:
    python3 convert_yolov8.py

Output:
    yolov8s.mlpackage - CoreML model package
"""

import os
import sys

def check_dependencies():
    """Check if required packages are installed."""
    try:
        import ultralytics
        import coremltools
        print("✅ All dependencies installed")
        return True
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("\nInstall with:")
        print("  pip install ultralytics coremltools")
        return False

def convert_model():
    """Convert YOLOv8s to CoreML format."""
    from ultralytics import YOLO
    
    print("\n🔄 Loading YOLOv8s model...")
    model = YOLO('yolov8s.pt')  # Downloads automatically if not present
    
    print("🔄 Converting to CoreML...")
    # Export with NMS built-in for easier iOS integration
    model.export(
        format='coreml',
        nms=True,           # Include Non-Maximum Suppression
        imgsz=640,          # Input image size
        half=False,         # Use FP32 for better accuracy
        int8=False,         # Don't quantize
    )
    
    print("\n✅ Conversion complete!")
    print("📁 Output: yolov8s.mlpackage")
    print("\n📋 Next steps:")
    print("  1. Drag 'yolov8s.mlpackage' into Xcode project")
    print("  2. Ensure it's added to the Lingoverse target")
    print("  3. Wait for Xcode to compile the model")

def main():
    print("=" * 50)
    print("   YOLOv8 → CoreML Conversion Tool")
    print("=" * 50)
    
    if not check_dependencies():
        sys.exit(1)
    
    convert_model()

if __name__ == "__main__":
    main()
