#!/usr/bin/env python3
"""
YOLOv8 to CoreML Conversion Script (Alternative Method)
Uses neuralnetwork format instead of mlprogram to avoid BlobWriter issues.
"""

import os
import sys

def convert_model():
    """Convert YOLOv8s to CoreML format using neuralnetwork."""
    from ultralytics import YOLO
    
    print("\n🔄 Loading YOLOv8s model...")
    model = YOLO('yolov8s.pt')  # Downloads automatically if not present
    
    print("🔄 Converting to CoreML (neuralnetwork format)...")
    # Export with neuralnetwork format instead of mlprogram
    result = model.export(
        format='coreml',
        nms=True,           # Include Non-Maximum Suppression
        imgsz=640,          # Input image size  
        half=False,         # Use FP32 for better accuracy
        int8=False,         # Don't quantize
    )
    
    print(f"\n✅ Conversion complete!")
    print(f"📁 Output: {result}")
    print("\n📋 Next steps:")
    print("  1. Drag the .mlpackage folder into Xcode project")
    print("  2. Ensure it's added to the Lingoverse target")
    print("  3. Wait for Xcode to compile the model")

if __name__ == "__main__":
    print("=" * 50)
    print("   YOLOv8 → CoreML Conversion Tool v2")
    print("=" * 50)
    convert_model()
