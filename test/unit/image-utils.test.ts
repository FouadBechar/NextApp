// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { transformImageToSquare } from "../../components/dashboard/image-utils";

describe("transformImageToSquare", () => {
  let realImage: any;
  let realCreateElement: any;
  let createObjectURLSpy: any;
  let revokeObjectURLSpy: any;

  beforeEach(() => {
    realImage = global.Image;
    realCreateElement = document.createElement;
    createObjectURLSpy = vi.spyOn(URL, "createObjectURL").mockImplementation(() => "blob:fake");
    revokeObjectURLSpy = vi.spyOn(URL, "revokeObjectURL").mockImplementation(() => {});
  });

  afterEach(() => {
    global.Image = realImage;
    // @ts-ignore
    document.createElement = realCreateElement;
    createObjectURLSpy.mockRestore();
    revokeObjectURLSpy.mockRestore();
    vi.restoreAllMocks();
  });

  it("resolves with a File when image loads and produces expected type/name", async () => {
    // mock Image to immediately call onload and set dimensions
    class MockImage {
      onload: (() => void) | null = null;
      onerror: ((err?: any) => void) | null = null;
      width = 600;
      height = 400;
      set src(_: string) {
        // simulate async load
        setTimeout(() => this.onload && this.onload(), 0);
      }
    }
    // mock canvas with toBlob
    // @ts-ignore
    document.createElement = (tag: string) => {
      if (tag === "canvas") {
        return {
          width: 256,
          height: 256,
          getContext: () => ({ drawImage: () => {} }),
          toBlob: (cb: (b: Blob | null) => void, type: string) => {
            const blob = new Blob(["a"], { type });
            cb(blob);
          },
        };
      }
      return realCreateElement.call(document, tag);
    };

    // @ts-ignore
    global.Image = MockImage;

    const file = new File(["test"], "input.jpg", { type: "image/jpeg" });

    const result = await transformImageToSquare(file, 256);

    expect(result).toBeInstanceOf(File);
    expect(result.type).toBe("image/jpeg");
    expect(result.name.endsWith(".jpg")).toBe(true);
    expect(revokeObjectURLSpy).toHaveBeenCalled();
  });

  it("rejects when image errors", async () => {
    class ErrorImage {
      onload: (() => void) | null = null;
      onerror: ((err?: any) => void) | null = null;
      set src(_: string) {
        setTimeout(() => this.onerror && this.onerror(new Error("load failed")), 0);
      }
    }
    // @ts-ignore
    global.Image = ErrorImage;
    // keep canvas simple
    // @ts-ignore
    document.createElement = (tag: string) => ({
      width: 256,
      height: 256,
      getContext: () => ({ drawImage: () => {} }),
      toBlob: (cb: (b: Blob | null) => void) => cb(new Blob(["a"], { type: "image/jpeg" })),
    });

    const file = new File(["x"], "in.png", { type: "image/png" });

    await expect(transformImageToSquare(file, 128)).rejects.toBeDefined();
  });
});
