"use client";

import { useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";

interface MediaUploaderProps {
  bucket: "products" | "categories" | "brands";
  images: string[];
  onChange: (images: string[]) => void;
  multiple?: boolean;
  label?: string;
}

export default function MediaUploader({
  bucket,
  images,
  onChange,
  multiple = true,
  label = "Upload Images",
}: MediaUploaderProps) {
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const supabase = createBrowserSupabaseClient();
  const allowedTypes = new Set(["image/jpeg", "image/png", "image/webp", "image/gif"]);

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    setUploading(true);
    setError(null);

    const uploadedUrls: string[] = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      if (!allowedTypes.has(file.type) || file.size > 5 * 1024 * 1024) {
        setError("Only JPEG, PNG, WebP, or GIF images up to 5 MB are allowed.");
        setUploading(false);
        return;
      }
      const fileExt = file.name.split(".").pop();
      const fileName = `${Date.now()}_${Math.random().toString(36).substring(2, 8)}.${fileExt}`;
      const filePath = fileName;

      const { error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(filePath, file, {
          cacheControl: "3600",
          upsert: true,
        });

      if (uploadError) {
        console.error("Upload error:", uploadError);
        setError(`Upload failed: ${uploadError.message}`);
        setUploading(false);
        return;
      }

      const { data: publicUrlData } = supabase.storage
        .from(bucket)
        .getPublicUrl(filePath);

      if (publicUrlData?.publicUrl) {
        uploadedUrls.push(publicUrlData.publicUrl);
      }
    }

    setUploading(false);

    if (multiple) {
      onChange([...images, ...uploadedUrls]);
    } else {
      onChange([uploadedUrls[0]]);
    }

    e.target.value = "";
  };

  const handleRemoveImage = (index: number) => {
    const next = [...images];
    next.splice(index, 1);
    onChange(next);
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
          {label}
        </label>
        {images.length > 0 && (
          <span className="text-xs text-slate-500 font-medium">
            {images.length} image{images.length > 1 ? "s" : ""} selected
          </span>
        )}
      </div>

      {/* Image Preview Grid */}
      {images.length > 0 && (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
          {images.map((url, idx) => (
            <div
              key={`${url}-${idx}`}
              className="relative group rounded-2xl overflow-hidden border border-slate-200 bg-slate-50 aspect-square shadow-sm"
            >
              {/* eslint-disable-next-next/no-img-element */}
              <img
                src={url}
                alt={`Product image ${idx + 1}`}
                className="w-full h-full object-cover"
                onError={(e) => {
                  (e.target as HTMLElement).style.display = "none";
                }}
              />

              {/* Main Badge for First Image */}
              {idx === 0 && (
                <span className="absolute top-2 left-2 px-2 py-0.5 text-[10px] font-extrabold rounded-md bg-slate-900 text-white shadow-sm">
                  Primary
                </span>
              )}

              {/* Delete Overlay */}
              <div className="absolute inset-0 bg-slate-900/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                <button
                  type="button"
                  onClick={() => handleRemoveImage(idx)}
                  className="px-3 py-1.5 rounded-xl bg-red-600 text-white text-xs font-bold hover:bg-red-700 transition-colors shadow-md flex items-center gap-1"
                  title="Remove image"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                    <polyline points="3 6 5 6 21 6" />
                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                  </svg>
                  Remove
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Drag & Drop File Upload Box */}
      <div className="relative border-2 border-dashed border-slate-300 hover:border-slate-800 rounded-2xl p-8 text-center bg-slate-50 hover:bg-slate-100/60 transition-all cursor-pointer group">
        <input
          type="file"
          accept="image/jpeg,image/png,image/webp,image/gif"
          multiple={multiple}
          onChange={handleFileUpload}
          disabled={uploading}
          className="absolute inset-0 w-full h-full opacity-0 cursor-pointer disabled:cursor-not-allowed z-10"
        />
        <div className="flex flex-col items-center justify-center space-y-2 pointer-events-none">
          <div className="w-12 h-12 rounded-2xl bg-white border border-slate-200 text-slate-700 flex items-center justify-center shadow-sm group-hover:scale-105 transition-transform">
            {uploading ? (
              <div className="w-5 h-5 border-2 border-slate-800 border-t-transparent rounded-full animate-spin" />
            ) : (
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                <polyline points="17 8 12 3 7 8" />
                <line x1="12" y1="3" x2="12" y2="15" />
              </svg>
            )}
          </div>
          <div>
            <p className="text-sm font-bold text-slate-900">
              {uploading
                ? "Uploading files to Supabase Storage..."
                : "Click to upload or drag & drop files"}
            </p>
            <p className="text-xs text-slate-500 mt-1 font-medium">
              JPEG, PNG, WebP, or GIF up to 5 MB (stored in <code className="px-1.5 py-0.5 bg-slate-200 text-slate-800 rounded font-mono text-[11px]">{bucket}</code>)
            </p>
          </div>
        </div>
      </div>

      {error && (
        <p className="text-xs font-semibold text-red-700 bg-red-50 p-3 rounded-xl border border-red-200">
          {error}
        </p>
      )}
    </div>
  );
}
