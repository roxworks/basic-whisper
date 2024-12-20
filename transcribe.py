import whisper
import os
import subprocess
import sys

def extract_audio(input_file, output_file):
    # Extract audio from video using ffmpeg
    # -i input_file: input video file
    # -ar 16000: set audio sample rate to 16000 Hz (recommended for Whisper)
    # -ac 1: convert to mono channel
    # -c:a pcm_s16le: use raw PCM 16-bit little-endian audio encoding
    subprocess.run([
        'ffmpeg', '-i', input_file, '-vn', '-ar', '16000', '-ac', '1', '-c:a', 'pcm_s16le', output_file
    ], check=True)

def transcribe_audio(input_file, model_type="base"):
    # Load the Whisper model
    model = whisper.load_model(model_type)
    # Transcribe the audio
    result = model.transcribe(input_file, verbose=True)
    return result

def write_srt(segments, output_file):
    # Write segments to SRT file
    with open(output_file, 'w', encoding='utf-8') as srt:
        for i, segment in enumerate(segments, start=1):
            start = format_timestamp(segment['start'])
            end = format_timestamp(segment['end'])
            text = segment['text'].strip()
            srt.write(f"{i}\n{start} --> {end}\n{text}\n\n")

def format_timestamp(seconds):
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    ms = int((seconds - int(seconds)) * 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{ms:03d}"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 transcribe.py <input_video_file>")
        sys.exit(1)

    input_video = sys.argv[1]
    base_name = os.path.splitext(os.path.basename(input_video))[0]
    audio_file = f"{base_name}.wav"
    srt_file = f"{base_name}.srt"

    # Extract audio from the input video
    extract_audio(input_video, audio_file)

    # Transcribe the extracted audio
    result = transcribe_audio(audio_file, model_type="base")

    # Write the transcription to an SRT file
    write_srt(result["segments"], srt_file)

    print(f"Transcription complete. Subtitles saved to {srt_file}")
