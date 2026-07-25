"use client";

import { useState, useRef, useEffect, useId, useCallback } from "react";

export interface CustomSelectOption {
  value: string;
  label: string;
  sublabel?: string;
  badge?: string;
}

interface CustomSelectProps {
  options: CustomSelectOption[];
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  disabled?: boolean;
  searchable?: boolean;
  size?: "sm" | "md";
  variant?: "default" | "table" | "ghost";
}

export default function CustomSelect({
  options,
  value,
  onChange,
  placeholder = "Select option...",
  className = "",
  disabled = false,
  searchable = false,
  size = "md",
  variant = "default",
}: CustomSelectProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [focusedIndex, setFocusedIndex] = useState(-1);
  const [dropUp, setDropUp] = useState(false);

  const containerRef = useRef<HTMLDivElement>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLDivElement>(null);
  const uniqueId = useId();

  const selectedOption = options.find((o) => o.value === value);

  // Auto-enable search if list is long
  const showSearch = searchable || options.length > 7;

  const filteredOptions = showSearch && searchTerm.trim()
    ? options.filter(
        (o) =>
          o.label.toLowerCase().includes(searchTerm.toLowerCase()) ||
          (o.sublabel && o.sublabel.toLowerCase().includes(searchTerm.toLowerCase()))
      )
    : options;

  // Calculate opening direction (dropUp vs dropDown) when opening
  const updatePosition = useCallback(() => {
    if (containerRef.current) {
      const rect = containerRef.current.getBoundingClientRect();
      const viewportHeight = window.innerHeight;
      // Space needed below container
      const spaceBelow = viewportHeight - rect.bottom;
      // If space below is less than 240px and space above is larger, drop upwards
      if (spaceBelow < 240 && rect.top > spaceBelow) {
        setDropUp(true);
      } else {
        setDropUp(false);
      }
    }
  }, []);

  const handleOpenToggle = () => {
    if (disabled) return;
    if (!isOpen) {
      updatePosition();
      setIsOpen(true);
      setSearchTerm("");
      setFocusedIndex(-1);
    } else {
      setIsOpen(false);
    }
  };

  // Focus search input on open if present
  useEffect(() => {
    if (isOpen && showSearch && searchInputRef.current) {
      setTimeout(() => {
        searchInputRef.current?.focus();
      }, 50);
    }
  }, [isOpen, showSearch]);

  // Click outside listener
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Keyboard navigation
  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setIsOpen(false);
      } else if (e.key === "ArrowDown") {
        e.preventDefault();
        setFocusedIndex((prev) => (prev < filteredOptions.length - 1 ? prev + 1 : 0));
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setFocusedIndex((prev) => (prev > 0 ? prev - 1 : filteredOptions.length - 1));
      } else if (e.key === "Enter") {
        e.preventDefault();
        if (focusedIndex >= 0 && focusedIndex < filteredOptions.length) {
          onChange(filteredOptions[focusedIndex].value);
          setIsOpen(false);
        }
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, focusedIndex, filteredOptions, onChange]);

  // Ensure focused item scrolls into view inside popup list
  useEffect(() => {
    if (focusedIndex >= 0 && listRef.current) {
      const itemEl = listRef.current.children[focusedIndex] as HTMLElement;
      if (itemEl) {
        itemEl.scrollIntoView({ block: "nearest", behavior: "smooth" });
      }
    }
  }, [focusedIndex]);

  // Variant & sizing classes
  const isSm = size === "sm";

  const triggerBase =
    "w-full flex items-center justify-between transition-all duration-150 border disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer select-none font-medium";

  const triggerVariantClasses = {
    default:
      "bg-slate-50 hover:bg-slate-100/80 border-slate-200 text-slate-900 focus:ring-2 focus:ring-slate-900 focus:border-slate-900 shadow-2xs",
    table:
      "bg-white hover:bg-slate-50 border-slate-200 text-slate-800 focus:ring-2 focus:ring-slate-900 shadow-2xs",
    ghost:
      "bg-transparent hover:bg-slate-100 border-transparent text-slate-800 focus:ring-2 focus:ring-slate-400",
  }[variant];

  const triggerSizeClasses = isSm
    ? "px-3 py-1.5 text-xs rounded-lg min-h-[34px]"
    : "px-3.5 py-2 text-sm rounded-xl min-h-[40px]";

  return (
    <div ref={containerRef} className={`relative inline-block w-full text-left ${className}`}>
      {/* Trigger Button */}
      <button
        id={`custom-select-${uniqueId}`}
        type="button"
        disabled={disabled}
        aria-haspopup="listbox"
        aria-expanded={isOpen}
        onClick={handleOpenToggle}
        className={`${triggerBase} ${triggerVariantClasses} ${triggerSizeClasses} ${
          isOpen ? "ring-2 ring-slate-900 border-slate-900 bg-white" : ""
        }`}
      >
        <span className="truncate flex items-center gap-2">
          {selectedOption ? (
            <>
              <span className="truncate">{selectedOption.label}</span>
              {selectedOption.badge && (
                <span className="px-2 py-0.5 text-[10px] font-semibold rounded-full bg-slate-200 text-slate-700">
                  {selectedOption.badge}
                </span>
              )}
            </>
          ) : (
            <span className="text-slate-400 font-normal">{placeholder}</span>
          )}
        </span>
        <svg
          className={`w-4 h-4 text-slate-400 transition-transform duration-200 shrink-0 ml-2 ${
            isOpen ? "rotate-180 text-slate-700" : ""
          }`}
          fill="none"
          stroke="currentColor"
          strokeWidth="2.5"
          viewBox="0 0 24 24"
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>

      {/* Floating Popup List */}
      {isOpen && (
        <div
          tabIndex={-1}
          style={{ zIndex: 9999 }}
          className={`absolute left-0 right-0 ${
            dropUp ? "bottom-full mb-1.5" : "top-full mt-1.5"
          } min-w-[200px] bg-white border border-slate-200 rounded-2xl shadow-2xl overflow-hidden py-1 transition-all duration-150 animate-in fade-in zoom-in-95`}
        >
          {/* Optional Search Bar inside Menu */}
          {showSearch && (
            <div className="p-2 border-b border-slate-100 bg-slate-50/50">
              <input
                ref={searchInputRef}
                type="text"
                value={searchTerm}
                onChange={(e) => {
                  setSearchTerm(e.target.value);
                  setFocusedIndex(0);
                }}
                placeholder="Search..."
                className="w-full px-3 py-1.5 text-xs rounded-lg bg-white border border-slate-200 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:border-slate-800"
              />
            </div>
          )}

          {/* Options List */}
          <div
            ref={listRef}
            role="listbox"
            className="max-h-60 overflow-y-auto divide-y divide-slate-50"
          >
            {filteredOptions.length === 0 ? (
              <div className="px-4 py-3 text-xs text-slate-400 text-center italic">
                No matching options
              </div>
            ) : (
              filteredOptions.map((opt, index) => {
                const isSelected = opt.value === value;
                const isFocused = index === focusedIndex;

                return (
                  <div
                    key={opt.value}
                    role="option"
                    aria-selected={isSelected}
                    onClick={() => {
                      onChange(opt.value);
                      setIsOpen(false);
                    }}
                    onMouseEnter={() => setFocusedIndex(index)}
                    className={`px-3.5 py-2.5 text-xs font-medium cursor-pointer transition-colors flex items-center justify-between ${
                      isSelected
                        ? "bg-slate-900 text-white font-semibold"
                        : isFocused
                        ? "bg-slate-100 text-slate-900"
                        : "text-slate-800 hover:bg-slate-50"
                    }`}
                  >
                    <div className="flex flex-col truncate pr-2">
                      <span className="truncate">{opt.label}</span>
                      {opt.sublabel && (
                        <span
                          className={`text-[10px] ${
                            isSelected ? "text-slate-300" : "text-slate-500"
                          }`}
                        >
                          {opt.sublabel}
                        </span>
                      )}
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      {opt.badge && (
                        <span
                          className={`px-2 py-0.5 text-[10px] font-bold rounded-full ${
                            isSelected
                              ? "bg-slate-800 text-slate-200"
                              : "bg-slate-100 text-slate-600"
                          }`}
                        >
                          {opt.badge}
                        </span>
                      )}
                      {isSelected && (
                        <svg
                          className="w-3.5 h-3.5 text-white stroke-3"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <polyline points="20 6 9 17 4 12" />
                        </svg>
                      )}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>
      )}
    </div>
  );
}
