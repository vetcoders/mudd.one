//! mudd-core — Veterinary ultrasound processing & ML dataset preparation
//!
//! ## Pipeline
//!
//! ```text
//! RawFrame → CroppedFrame → ProcessedFrame → AnnotatedFrame → ExportItem
//! ```
//!
//! Created by vetcoders (c)2026

pub mod dicom;
pub mod export;
pub mod imaging;
pub mod inference;
pub mod pipeline;
pub mod video;
