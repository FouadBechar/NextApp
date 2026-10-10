/**
 * transformImageToSquare
 * - crops the image to a square centered on the shortest side
 * - resizes it to `size` x `size`
 * - outputs a File with a suitable extension and MIME type
 */
export async function transformImageToSquare(file: File, size = 512): Promise<File> {
  return new Promise<File>((resolve, reject) => {
    const url = URL.createObjectURL(file);
    const img = new Image();
    img.onload = () => {
      try {
        const minSide = Math.min(img.width, img.height);
        const sx = Math.floor((img.width - minSide) / 2);
        const sy = Math.floor((img.height - minSide) / 2);
        const canvas = document.createElement("canvas");
        canvas.width = size;
        canvas.height = size;
        const ctx = canvas.getContext("2d");
        if (!ctx) throw new Error("Canvas 2D context unavailable");
        ctx.drawImage(img, sx, sy, minSide, minSide, 0, 0, size, size);
        const outputType =
          file.type === "image/png" || file.type === "image/webp"
            ? file.type
            : "image/jpeg";
        canvas.toBlob(
          (blob) => {
            URL.revokeObjectURL(url);
            if (!blob) return reject(new Error("Failed to convert canvas to blob"));
            let name = file.name;
            try {
              const extMap: Record<string, string> = {
                "image/jpeg": "jpg",
                "image/png": "png",
                "image/webp": "webp",
              };
              const wantedExt = extMap[outputType] || "jpg";
              const base = name.replace(/\.[^.]+$/, "");
              name = `${base}.${wantedExt}`;
            } catch (e) {
              /* ignore */
            }
            const newFile = new File([blob], name, { type: blob.type });
            resolve(newFile);
          },
          outputType,
          0.92
        );
      } catch (err) {
        URL.revokeObjectURL(url);
        reject(err);
      }
    };
    img.onerror = (err) => {
      URL.revokeObjectURL(url);
      reject(err);
    };
    img.src = url;
  });
}
