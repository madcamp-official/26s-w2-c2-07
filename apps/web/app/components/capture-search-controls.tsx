import { Search } from "lucide-react";
import { captureTypeLabels } from "../components";
import type { CaptureType } from "../data";

interface CaptureSearchControlsProps {
  query: string;
  type: "all" | CaptureType;
  tagId: string;
  tags: Array<[string, string]>;
  onQueryChange: (value: string) => void;
  onTypeChange: (value: "all" | CaptureType) => void;
  onTagChange: (value: string) => void;
  compact?: boolean;
}

export function CaptureSearchControls({
  query,
  type,
  tagId,
  tags,
  onQueryChange,
  onTypeChange,
  onTagChange,
  compact = false,
}: CaptureSearchControlsProps) {
  return (
    <div className={`capture-search-controls ${compact ? "compact" : ""}`}>
      <label className="capture-search-input">
        <Search />
        <input
          value={query}
          onChange={(event) => onQueryChange(event.target.value)}
          placeholder="글감 검색"
        />
      </label>
      <select
        value={type}
        onChange={(event) =>
          onTypeChange(event.target.value as "all" | CaptureType)
        }
        aria-label="글감 형태"
      >
        <option value="all">모든 형태</option>
        {Object.entries(captureTypeLabels).map(([value, label]) => (
          <option key={value} value={value}>
            {label}
          </option>
        ))}
      </select>
      <select
        value={tagId}
        onChange={(event) => onTagChange(event.target.value)}
        aria-label="글감 태그"
      >
        <option value="all">모든 태그</option>
        {tags.map(([id, name]) => (
          <option key={id} value={id}>
            #{name}
          </option>
        ))}
      </select>
    </div>
  );
}
