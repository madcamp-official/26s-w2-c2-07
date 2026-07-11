import { createRequire } from "node:module";
import { Document, HeadingLevel, Packer, Paragraph, TextRun } from "docx";
import PDFDocument from "pdfkit";
import type { ExportProjectFormat } from "../schemas/project.schema.js";
import * as documentsRepository from "../repositories/documents.repository.js";
import * as projectsRepository from "../repositories/projects.repository.js";
import { HttpError } from "../utils/http-error.js";

// PDFKit 기본(Helvetica 등 PDF 표준 14폰트)은 한글 글리프가 없어 그대로 쓰면 글자가 깨진다.
// 한글을 지원하는 폰트를 임베드해서 써야 한다. npm 패키지로 받아두면 OS에 상관없이 항상 같은 경로에서 찾을 수 있다.
const require = createRequire(import.meta.url);
const KOREAN_FONT_PATH = require.resolve(
  "@fontsource/noto-sans-kr/files/noto-sans-kr-korean-400-normal.woff",
);

export interface ExportedFile {
  buffer: Buffer;
  filename: string;
  contentType: string;
}

const contentTypes: Record<ExportProjectFormat, string> = {
  pdf: "application/pdf",
  docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  txt: "text/plain; charset=utf-8",
};

export async function exportProject(
  userId: string,
  projectId: string,
  format: ExportProjectFormat,
): Promise<ExportedFile> {
  const project = await projectsRepository.getProjectById(userId, projectId);
  if (project.status !== "done") {
    throw HttpError.forbidden("완료된 프로젝트만 다운로드할 수 있습니다.");
  }

  const documents = await documentsRepository.listDocuments(userId, projectId);
  const buffer =
    format === "pdf"
      ? await buildPdf(project.title, documents)
      : format === "docx"
        ? await buildDocx(project.title, documents)
        : buildTxt(project.title, documents);

  return { buffer, filename: `${project.title}.${format}`, contentType: contentTypes[format] };
}

function buildTxt(title: string, documents: { title: string; content: string }[]) {
  const body = documents.map((doc) => `${doc.title}\n\n${doc.content}`).join("\n\n---\n\n");
  return Buffer.from(`${title}\n\n${body}`, "utf-8");
}

function buildPdf(title: string, documents: { title: string; content: string }[]) {
  return new Promise<Buffer>((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50 });
    const chunks: Buffer[] = [];

    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    doc.registerFont("NotoSansKR", KOREAN_FONT_PATH);
    doc.font("NotoSansKR");

    doc.fontSize(20).text(title, { align: "left" });
    doc.moveDown(2);

    documents.forEach((document, index) => {
      if (index > 0) doc.addPage();
      doc.fontSize(16).text(document.title);
      doc.moveDown();
      doc.fontSize(11).text(document.content, { align: "left" });
    });

    doc.end();
  });
}

async function buildDocx(title: string, documents: { title: string; content: string }[]) {
  const children: Paragraph[] = [
    new Paragraph({ text: title, heading: HeadingLevel.TITLE }),
  ];

  for (const document of documents) {
    children.push(new Paragraph({ text: document.title, heading: HeadingLevel.HEADING_1 }));
    for (const line of document.content.split("\n")) {
      children.push(new Paragraph({ children: [new TextRun(line)] }));
    }
  }

  const doc = new Document({ sections: [{ children }] });
  return Packer.toBuffer(doc);
}
