"use client";
import React, { useEffect, useRef, useState } from "react";
import { createClient } from "@/utils/supabase/client";

const MAX_FILE_SIZE_BYTES = 18 * 1024 * 1024;
const MAX_FILE_SIZE_LABEL = "18MB";

export default function Contact() {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [responseMessage, setResponseMessage] = useState("");
  const [responseStatus, setResponseStatus] = useState<
    "success" | "error" | "stored" | "idle"
  >("idle");
  const [selectedFileName, setSelectedFileName] = useState("");
  const [fileError, setFileError] = useState<string | null>(null);

  const formRef = useRef<HTMLFormElement | null>(null);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const supabaseRef = useRef<ReturnType<typeof createClient> | null>(null);

  useEffect(() => {
    const openBtn = document.getElementById("open-btn") as HTMLElement | null;
    if (!openBtn) {
      return;
    }

    const handleExternalOpen = () => setIsOpen(true);
    openBtn.addEventListener("click", handleExternalOpen);
    return () => {
      openBtn.removeEventListener("click", handleExternalOpen);
    };
  }, []);

  useEffect(() => {
    const openBtn = document.getElementById("open-btn") as HTMLElement | null;
    if (openBtn) {
      openBtn.style.display = isOpen ? "none" : "flex";
    }
  }, [isOpen]);

  function resetFormState() {
    setResponseMessage("");
    setResponseStatus("idle");
    setSelectedFileName("");
    setFileError(null);
  }

  function handleClose() {
    setIsOpen(false);
    resetFormState();
  }

  function updateResponse(
    message: string,
    status: "success" | "error" | "stored" | "idle",
  ) {
    setResponseMessage(message);
    setResponseStatus(status);
  }

  function getSupabaseClient() {
    if (!supabaseRef.current) {
      supabaseRef.current = createClient();
    }

    return supabaseRef.current;
  }

  function handleFileChange(event: React.ChangeEvent<HTMLInputElement>) {
    const files = event.target.files;
    if (!files || files.length === 0) {
      setSelectedFileName("");
      setFileError(null);
      return;
    }

    const file = files[0];
    if (file.size > MAX_FILE_SIZE_BYTES) {
      setSelectedFileName("");
      setFileError(`File too large (max ${MAX_FILE_SIZE_LABEL}).`);
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
      return;
    }

    setSelectedFileName(file.name);
    setFileError(null);
  }

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (isLoading) {
      return;
    }

    const form = formRef.current;
    if (!form) {
      updateResponse("Unable to submit form right now.", "error");
      return;
    }

    const fileInput = fileInputRef.current;
    const file = fileInput?.files?.[0] ?? null;

    if (file && file.size > MAX_FILE_SIZE_BYTES) {
      updateResponse(`File too large (max ${MAX_FILE_SIZE_LABEL}).`, "error");
      return;
    }

    setIsLoading(true);
    updateResponse("", "idle");

    const formData = new FormData(form);
    let uploadedBucket = "";
    let uploadedObjectPath = "";
    let uploadedFileStored = false;

    try {
      if (file) {
        updateResponse("Uploading attachment...", "idle");

        const uploadPrepResponse = await fetch("/api/contact/upload-url", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            fileName: file.name,
            fileType: file.type,
            fileSize: file.size,
          }),
        });

        const uploadPrepData = await uploadPrepResponse
          .json()
          .catch(() => ({}) as Record<string, unknown>);
        if (!uploadPrepResponse.ok) {
          const uploadPrepMessage =
            typeof uploadPrepData?.message === "string"
              ? uploadPrepData.message
              : uploadPrepResponse.status === 413
                ? `File too large (max ${MAX_FILE_SIZE_LABEL}).`
                : "Unable to prepare attachment upload.";
          updateResponse(uploadPrepMessage, "error");
          return;
        }

        const bucket =
          typeof uploadPrepData?.bucket === "string"
            ? uploadPrepData.bucket
            : "";
        const objectPath =
          typeof uploadPrepData?.objectPath === "string"
            ? uploadPrepData.objectPath
            : "";
        const token =
          typeof uploadPrepData?.token === "string" ? uploadPrepData.token : "";
        const publicUrl =
          typeof uploadPrepData?.publicUrl === "string"
            ? uploadPrepData.publicUrl
            : "";

        if (!bucket || !objectPath || !token || !publicUrl) {
          updateResponse(
            "Attachment upload setup returned incomplete data.",
            "error",
          );
          return;
        }

        const supabase = getSupabaseClient();
        const { error: uploadError } = await supabase.storage
          .from(bucket)
          .uploadToSignedUrl(objectPath, token, file, {
            contentType: file.type || "application/octet-stream",
          });

        if (uploadError) {
          updateResponse(
            `Attachment upload failed: ${uploadError.message}`,
            "error",
          );
          return;
        }

        uploadedBucket = bucket;
        uploadedObjectPath = objectPath;
        uploadedFileStored = true;

        formData.delete("file");
        formData.set("fileName", file.name);
        formData.set("fileUrl", publicUrl);
      }

      updateResponse("Sending message...", "idle");

      const response = await fetch("/api/contact", {
        method: "POST",
        body: formData,
      });

      const data = await response
        .json()
        .catch(() => ({}) as Record<string, unknown>);
      const message =
        typeof data?.message === "string"
          ? data.message
          : response.status === 413
            ? `Attachment too large for this upload path. Please use a file smaller than ${MAX_FILE_SIZE_LABEL}.`
            : response.ok
              ? "Submission complete."
              : "Unable to submit form.";
      const status =
        typeof data?.status === "string"
          ? data.status
          : response.ok
            ? "success"
            : "error";

      if (
        !response.ok &&
        uploadedFileStored &&
        uploadedBucket &&
        uploadedObjectPath
      ) {
        void fetch("/api/contact/upload-url/delete", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            bucket: uploadedBucket,
            objectPath: uploadedObjectPath,
          }),
        });
      }

      updateResponse(
        message,
        status === "success" || status === "stored"
          ? (status as "success" | "stored")
          : "error",
      );

      if (status === "success") {
        form.reset();
        setSelectedFileName("");
      }
    } catch (error: unknown) {
      if (uploadedFileStored && uploadedBucket && uploadedObjectPath) {
        void fetch("/api/contact/upload-url/delete", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            bucket: uploadedBucket,
            objectPath: uploadedObjectPath,
          }),
        });
      }

      const message = error instanceof Error ? error.message : String(error);
      updateResponse(`Submission failed: ${message}`, "error");
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <>
      <div id="form-container" className={isOpen ? "open" : ""}>
        <div
          id="loading-overlay"
          role="status"
          hidden={!isLoading}
          className={`loading-overlay${isLoading ? " visible" : ""}`}
        >
          <div>
            <div className="spinner02" aria-hidden="true" />
            Sending...
          </div>
        </div>

        <form
          ref={formRef}
          id="my-form"
          className="animated"
          encType="multipart/form-data"
          method="POST"
          onSubmit={handleSubmit}
        >
          <button
            type="button"
            id="close-btn2"
            title="Close contact form"
            onClick={handleClose}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 256 256"
              width="22px"
              height="22px"
              fillRule="nonzero"
            >
              <g
                xmlns="http://www.w3.org/2000/svg"
                fill="currentColor"
                fillRule="nonzero"
                stroke="none"
                strokeWidth="1"
                strokeLinecap="butt"
                strokeLinejoin="miter"
                strokeMiterlimit="10"
                strokeDasharray=""
                strokeDashoffset="0"
                fontFamily="none"
                fontWeight="none"
                fontSize="none"
                textAnchor="inherit"
              >
                <g transform="scale(3.55556,3.55556)">
                  <path d="M19,15c-1.023,0 -2.04812,0.39087 -2.82812,1.17188c-1.562,1.562 -1.562,4.09425 0,5.65625l14.17188,14.17188l-14.17187,14.17188c-1.562,1.562 -1.562,4.09425 0,5.65625c0.78,0.78 1.80513,1.17188 2.82813,1.17188c1.023,0 2.04812,-0.39088 2.82813,-1.17187l14.17188,-14.17187l14.17188,14.17188c1.56,1.562 4.09525,1.562 5.65625,0c1.563,-1.563 1.563,-4.09325 0,-5.65625l-14.17187,-14.17187l14.17188,-14.17187c1.562,-1.562 1.562,-4.09425 0,-5.65625c-1.56,-1.561 -4.09625,-1.562 -5.65625,0l-14.17187,14.17188l-14.17187,-14.17187c-0.78,-0.78 -1.80513,-1.17187 -2.82812,-1.17187z" />
                </g>
              </g>
            </svg>
          </button>

          <h2>Contact Form</h2>

          <p
            id="responseMessage"
            className={`pp00 ${responseStatus === "success" ? "success" : responseStatus === "error" ? "error" : ""}`}
            aria-live="polite"
          >
            {responseMessage}
          </p>

          <input
            className="input02"
            type="text"
            name="prenom"
            placeholder="First Name"
            required
          />
          <input
            className="input02"
            type="text"
            name="nom"
            placeholder="Last Name"
            required
          />
          <input
            className="input02"
            type="email"
            name="email"
            placeholder="Email Address"
            required
          />
          <textarea
            className="textarea02"
            name="textarea"
            placeholder="Your message"
          />

          <label htmlFor="file-input" className="sr-only">
            Attach a file (optional)
          </label>
          <input
            className="input002"
            type="file"
            name="file"
            id="file-input"
            ref={fileInputRef}
            onChange={handleFileChange}
          />

          <div id="file-preview" className="preview">
            {selectedFileName ? `Selected: ${selectedFileName}` : ""}
            {fileError ? <span className="file-error">{fileError}</span> : null}
          </div>

          <button className="button2" type="submit" disabled={isLoading}>
            {isLoading ? "Sending..." : "Send"}
          </button>
        </form>
      </div>
    </>
  );
}
