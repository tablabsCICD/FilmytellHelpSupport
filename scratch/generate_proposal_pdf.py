import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_RIGHT
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """Canvas that enables running header and dynamic 'Page X of Y' footer."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 7.5)
        self.setFillColor(colors.HexColor("#64748B"))
        
        # Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(40, 755, "Filmytell Help & Support — Backend Architecture & Strategy Proposal")
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(40, 747, 612 - 40, 747)
            
        # Footer
        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.5)
        self.line(40, 36, 612 - 40, 36)
        
        self.drawString(40, 24, "CONFIDENTIAL — FOR INTERNAL TEAM & MANAGEMENT REVIEW ONLY")
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(612 - 40, 24, page_text)
        self.restoreState()


def build_pdf(filename):
    # Generates a clean 2-page executive proposal
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=40,
        rightMargin=40,
        topMargin=40,
        bottomMargin=42
    )

    primary_color = colors.HexColor("#0F172A") # Slate 900
    brand_color = colors.HexColor("#4F46E5")   # Indigo 600
    accent_dark = colors.HexColor("#1E293B")   # Slate 800
    text_dark = colors.HexColor("#334155")     # Slate 700
    bg_light = colors.HexColor("#F8FAFC")      # Slate 50
    border_color = colors.HexColor("#E2E8F0")

    doc_title_style = ParagraphStyle(
        'DocTitle',
        fontName='Helvetica-Bold',
        fontSize=17,
        leading=20,
        textColor=primary_color,
        spaceAfter=2
    )
    doc_sub_style = ParagraphStyle(
        'DocSub',
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13,
        textColor=brand_color,
        spaceAfter=6
    )
    meta_style = ParagraphStyle(
        'MetaStyle',
        fontName='Helvetica',
        fontSize=8,
        leading=11,
        textColor=colors.HexColor("#64748B")
    )
    h1_style = ParagraphStyle(
        'H1',
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=14,
        textColor=primary_color,
        spaceBefore=7,
        spaceAfter=4,
        keepWithNext=True
    )
    body_style = ParagraphStyle(
        'Body',
        fontName='Helvetica',
        fontSize=8,
        leading=11.5,
        textColor=text_dark,
        spaceAfter=4,
        alignment=TA_LEFT
    )
    callout_style = ParagraphStyle(
        'Callout',
        fontName='Helvetica',
        fontSize=8,
        leading=11.5,
        textColor=colors.HexColor("#1E1B4B")
    )
    table_cell = ParagraphStyle(
        'TableCell',
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=text_dark
    )
    table_header = ParagraphStyle(
        'TableHeader',
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10.5,
        textColor=colors.white
    )
    bullet_style = ParagraphStyle(
        'BulletText',
        fontName='Helvetica',
        fontSize=7.8,
        leading=11,
        textColor=text_dark,
        leftIndent=10,
        firstLineIndent=-6,
        spaceAfter=2
    )

    story = []

    # ================= PAGE 1 =================
    header_table_data = [
        [
            Paragraph("Filmytell OTT Engineering Architecture", ParagraphStyle('TopBrand', fontName='Helvetica-Bold', fontSize=9, textColor=brand_color)),
            Paragraph("Date: August 2026 | Document Ver: 1.0", ParagraphStyle('DateText', fontName='Helvetica', fontSize=8, textColor=colors.HexColor("#64748B"), alignment=TA_RIGHT))
        ],
        [
            Paragraph("Help & Support System — Backend & DB Architecture Proposal", doc_title_style),
            ""
        ],
        [
            Paragraph("Strategy Analysis: Standalone Support Service vs. Existing OTT Monolith Extension", doc_sub_style),
            ""
        ],
        [
            Paragraph("<b>Target Audience:</b> Engineering Management, Backend Tech Leads, Architecture Committee", meta_style),
            Paragraph("<b>Domain:</b> Support Desk, Realtime Chat, AI Auto-triaging, Ticketing", ParagraphStyle('Scope', fontName='Helvetica', fontSize=8, textColor=colors.HexColor("#64748B"), alignment=TA_RIGHT))
        ]
    ]
    header_table = Table(header_table_data, colWidths=[382, 150])
    header_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('SPAN', (0,1), (1,1)),
        ('SPAN', (0,2), (1,2)),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1),
        ('TOPPADDING', (0,0), (-1,-1), 1),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(header_table)
    story.append(HRFlowable(width="100%", thickness=1, color=brand_color, spaceBefore=3, spaceAfter=6))

    # Executive Verdict Callout
    summary_html = (
        "<b>EXECUTIVE RECOMMENDATION: Hybrid Microservice (Dedicated Backend + Database)</b><br/>"
        "We recommend developing the <b>Filmytell Help & Support platform as an independent backend service with a dedicated PostgreSQL database</b>, connected to Filmytell Core via <b>JWT Auth Federation</b> and <b>Internal Context APIs</b>.<br/>"
        "<b>Key Justification:</b> Isolates streaming playback servers from heavy support loads (WebSockets, file uploads, AI queues), enables rapid independent deployments, and provides native tooling for ticket lifecycle state machines."
    )
    summary_p = Paragraph(summary_html, callout_style)
    summary_box = Table([[summary_p]], colWidths=[532])
    summary_box.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#EEF2FF")),
        ('BOX', (0,0), (-1,-1), 0.8, colors.HexColor("#C7D2FE")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(summary_box)
    story.append(Spacer(1, 4))

    # Section 1: Workload Comparison
    story.append(Paragraph("1. Workload Divergence: OTT Streaming Core vs. Help & Support Domain", h1_style))
    story.append(Paragraph(
        "The OTT video streaming platform and internal Help & Support service have fundamentally conflicting infrastructure demands:",
        body_style
    ))

    workload_data = [
        [
            Paragraph("Engineering Factor", table_header),
            Paragraph("Core OTT Streaming Backend", table_header),
            Paragraph("Help & Support Backend Service", table_header)
        ],
        [
            Paragraph("<b>Workload Pattern</b>", table_cell),
            Paragraph("High read throughput, low latency catalog browsing, heavy CDN video traffic.", table_cell),
            Paragraph("Long-lived WebSockets, live agent chat, periodic bulk reporting, state updates.", table_cell)
        ],
        [
            Paragraph("<b>Data Domain</b>", table_cell),
            Paragraph("Media catalogs, playback streams, watch history, subscriptions, payment invoices.", table_cell),
            Paragraph("Ticket lifecycles, delegations, SLAs, chat threads, KB articles, audit logs.", table_cell)
        ],
        [
            Paragraph("<b>AI / Automation</b>", table_cell),
            Paragraph("Recommendation engines & catalog search.", table_cell),
            Paragraph("LLM ticket auto-triaging, sentiment detection, auto-reply drafting, vector search.", table_cell)
        ],
        [
            Paragraph("<b>Failure Blast Radius</b>", table_cell),
            Paragraph("Critical: Server degradation immediately interrupts customer video playback.", table_cell),
            Paragraph("Operational: High support load must never degrade user streaming experience.", table_cell)
        ]
    ]
    workload_table = Table(workload_data, colWidths=[112, 210, 210])
    workload_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), primary_color),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('GRID', (0,0), (-1,-1), 0.5, border_color),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, bg_light]),
        ('TOPPADDING', (0,0), (-1,-1), 3.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3.5),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(workload_table)
    story.append(Spacer(1, 4))

    # Section 2: Options Evaluation
    story.append(Paragraph("2. Strategic Options Evaluation Matrix", h1_style))
    options_data = [
        [
            Paragraph("Option A: Extend Existing OTT Backend & DB", table_header),
            Paragraph("Option B: Dedicated Service & DB (Recommended)", table_header)
        ],
        [
            Paragraph(
                "<b>Pros:</b><br/>"
                "• No new server instances to deploy initially.<br/>"
                "• Direct foreign key joins to existing user/payment tables.<br/><br/>"
                "<b>Risks & Drawbacks:</b><br/>"
                "• <b>Shared Blast Radius:</b> Complex support reporting queries or large screenshot uploads could lock tables and degrade streaming APIs.<br/>"
                "• <b>Tied Release Cycles:</b> Any support bug fix requires redeploying the core OTT platform.<br/>"
                "• <b>Realtime Limits:</b> Hard to run thousands of long-lived chat WebSockets on existing REST backend.<br/>"
                "• <b>Security Risk:</b> Support agents operate within the core customer database context.",
                table_cell
            ),
            Paragraph(
                "<b>Pros:</b><br/>"
                "• <b>Zero Risk to Streaming:</b> Complete operational and database isolation.<br/>"
                "• <b>Modern Realtime Stack:</b> Built with WebSockets, Redis pub/sub, and async job queues (BullMQ/Celery) for AI processing.<br/>"
                "• <b>High Deployment Velocity:</b> Independent CI/CD pipeline allows daily updates to support workflows without touching OTT production.<br/>"
                "• <b>Strict RBAC:</b> Internal support agent tokens and roles are isolated.<br/><br/>"
                "<b>Tradeoff:</b> Requires maintaining a separate service & DB instance.",
                table_cell
            )
        ]
    ]
    options_table = Table(options_data, colWidths=[264, 268])
    options_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (0,0), colors.HexColor("#475569")),
        ('BACKGROUND', (1,0), (1,0), brand_color),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('GRID', (0,0), (-1,-1), 0.5, border_color),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white]),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(options_table)

    # Force exact 2-page structure
    story.append(PageBreak())

    # ================= PAGE 2 =================
    story.append(Paragraph("3. Target Architecture & Integration Blueprint", h1_style))
    story.append(Paragraph(
        "The standalone Help & Support service interfaces cleanly with Filmytell OTT via four core integration pillars:",
        body_style
    ))

    blueprint_data = [
        [
            Paragraph("Integration Pillar", table_header),
            Paragraph("Protocol / Method", table_header),
            Paragraph("Implementation Specification", table_header)
        ],
        [
            Paragraph("<b>1. Unified Authentication</b>", table_cell),
            Paragraph("Shared JWT / SSO Verification", table_cell),
            Paragraph("Support backend validates client JWTs using Filmytell's public key or introspection endpoint. Zero duplicated credentials.", table_cell)
        ],
        [
            Paragraph("<b>2. Customer Context</b>", table_cell),
            Paragraph("Internal Service-to-Service REST", table_cell),
            Paragraph("When agents view a ticket, the backend calls <code>GET /ott/api/users/{id}</code> to pull active plan, device type, and recent playback logs.", table_cell)
        ],
        [
            Paragraph("<b>3. Review & Rating Sync</b>", table_cell),
            Paragraph("Periodic Poller / Webhook", table_cell),
            Paragraph("Consumes existing <code>/ott/api/RatingAndRewiew/getAll/pages</code> to automatically ingest 1-2 star reviews into actionable support tickets.", table_cell)
        ],
        [
            Paragraph("<b>4. Media Attachments</b>", table_cell),
            Paragraph("S3 / GCS Presigned URLs", table_cell),
            Paragraph("User screenshots and video clips upload directly to object storage with time-limited signed URLs, preventing server memory bloat.", table_cell)
        ]
    ]
    blueprint_table = Table(blueprint_data, colWidths=[116, 136, 280])
    blueprint_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), primary_color),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('GRID', (0,0), (-1,-1), 0.5, border_color),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, bg_light]),
        ('TOPPADDING', (0,0), (-1,-1), 3.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3.5),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(blueprint_table)
    story.append(Spacer(1, 4))

    # Section 4: Recommended Tech Stack
    story.append(Paragraph("4. Recommended Technology Stack", h1_style))

    stack_data = [
        [
            Paragraph("Architecture Layer", table_header),
            Paragraph("Recommended Technology", table_header),
            Paragraph("Engineering Justification", table_header)
        ],
        [
            Paragraph("<b>Backend Runtime</b>", table_cell),
            Paragraph("<b>Node.js (NestJS / Fastify)</b><br/><i>Alternative: Python FastAPI</i>", table_cell),
            Paragraph("High I/O concurrency, built-in WebSocket support for live chat, structured modular architecture, seamless integration with AI SDKs.", table_cell)
        ],
        [
            Paragraph("<b>Primary Database</b>", table_cell),
            Paragraph("<b>PostgreSQL 16+</b>", table_cell),
            Paragraph("ACID compliance for ticket states, JSONB for dynamic device telemetry, and <code>pgvector</code> for semantic Knowledge Base search.", table_cell)
        ],
        [
            Paragraph("<b>Cache & Job Queue</b>", table_cell),
            Paragraph("<b>Redis + BullMQ</b>", table_cell),
            Paragraph("Handles active agent presence, WebSocket pub/sub clustering, SLA breach countdown timers, and async AI auto-triaging queues.", table_cell)
        ],
        [
            Paragraph("<b>AI / LLM Engine</b>", table_cell),
            Paragraph("<b>Gemini API / OpenAI</b>", table_cell),
            Paragraph("Automated ticket category classification, sentiment analysis, priority assignment, and suggested smart replies for support agents.", table_cell)
        ]
    ]
    stack_table = Table(stack_data, colWidths=[100, 160, 272])
    stack_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), primary_color),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('GRID', (0,0), (-1,-1), 0.5, border_color),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, bg_light]),
        ('TOPPADDING', (0,0), (-1,-1), 3.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3.5),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(stack_table)
    story.append(Spacer(1, 4))

    # Section 5: Phased Implementation Roadmap
    story.append(Paragraph("5. Phased Implementation Roadmap", h1_style))
    roadmap_html = (
        "<b>• Phase 1: Core Service Scaffold & Auth Integration (Weeks 1–2):</b> Setup repository, configure PostgreSQL schema (Tickets, Messages, KB, Users), implement JWT validation middleware connected to Filmytell Auth, build core ticket CRUD and Kanban endpoints.<br/>"
        "<b>• Phase 2: Real-time Messaging & Review Ingestion (Weeks 3–4):</b> Deploy WebSocket gateway for live agent-user chat, integrate with <code>/RatingAndRewiew/getAll/pages</code> for automated ticket creation, setup S3/GCS presigned upload endpoints.<br/>"
        "<b>• Phase 3: AI Triaging & SLA Engine (Weeks 5–6):</b> Deploy BullMQ workers for SLA escalation timers, connect LLM pipeline for ticket categorization and smart suggestions, complete performance and security load tests."
    )
    story.append(Paragraph(roadmap_html, body_style))
    story.append(Spacer(1, 4))

    # Section 6: Action Items
    story.append(Paragraph("6. Immediate Action Items for Team Alignment", h1_style))
    action_items = [
        "1. <b>Architecture Sign-Off:</b> Align engineering management and backend leads on the dedicated service + PostgreSQL approach.",
        "2. <b>Select Backend Framework:</b> Finalize team preference between Node.js (NestJS/Fastify) and Python (FastAPI).",
        "3. <b>Expose Context Endpoint:</b> Backend team exposes/verifies <code>GET /ott/api/users/{id}</code> for customer profile context retrieval.",
        "4. <b>Infrastructure Provisioning:</b> Provision dedicated staging PostgreSQL, Redis, and S3/GCS bucket on cloud infrastructure."
    ]
    for act in action_items:
        story.append(Paragraph(act, bullet_style))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF successfully regenerated: {filename}")

if __name__ == "__main__":
    out_path = os.path.abspath(r"c:\Users\admin\.gemini\antigravity-ide\scratch\filmytell_help_support\Filmytell_Help_Support_Backend_Architecture_Proposal.pdf")
    build_pdf(out_path)
