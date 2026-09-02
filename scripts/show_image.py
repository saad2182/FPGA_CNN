"""Reconstruct the detector's 206 x 157 binary output from a simulator trace."""

from __future__ import annotations

import argparse
import struct
import zlib
from pathlib import Path

ROWS = 206
COLUMNS = 157
PIXEL_COUNT = ROWS * COLUMNS


def read_detection_bits(path: Path) -> list[int]:
    bits: list[int] = []

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        value = raw_line.strip()
        if value in {"0", "1"}:
            bits.append(int(value))

    if len(bits) < PIXEL_COUNT:
        raise ValueError(
            f"{path} contains {len(bits):,} binary samples; "
            f"at least {PIXEL_COUNT:,} are required."
        )

    # The testbench also records pipeline warm-up cycles. The final frame is the
    # last complete set of detector outputs. Invert it to match the original
    # visualizer: detected pixels are black, and the background is white.
    return [255 * (1 - bit) for bit in bits[-PIXEL_COUNT:]]


def png_chunk(chunk_type: bytes, data: bytes) -> bytes:
    checksum = zlib.crc32(chunk_type + data) & 0xFFFFFFFF
    return struct.pack(">I", len(data)) + chunk_type + data + struct.pack(">I", checksum)


def write_grayscale_png(path: Path, pixels: list[int]) -> None:
    # Each scanline begins with PNG filter type 0 (no filtering).
    scanlines = b"".join(
        b"\x00" + bytes(pixels[row * COLUMNS : (row + 1) * COLUMNS])
        for row in range(ROWS)
    )
    header = struct.pack(">IIBBBBB", COLUMNS, ROWS, 8, 0, 0, 0, 0)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", header)
        + png_chunk(b"IDAT", zlib.compress(scanlines, level=9))
        + png_chunk(b"IEND", b"")
    )
    path.write_bytes(png)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Simulator text output")
    parser.add_argument(
        "output",
        nargs="?",
        type=Path,
        default=Path("detections.png"),
        help="Destination PNG (default: detections.png)",
    )
    args = parser.parse_args()

    pixels = read_detection_bits(args.input)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    write_grayscale_png(args.output, pixels)

    print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
