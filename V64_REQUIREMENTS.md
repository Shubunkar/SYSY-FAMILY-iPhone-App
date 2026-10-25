# SYSY FAMILY V64 — Approved Redesign Requirements

This branch is the working branch for the next SYSY FAMILY iPhone app update. Keep the existing V63 data-safety safeguards and accounting behavior unless a requirement below explicitly changes them. Do not release/build until source changes are implemented and reviewed.

## Brand and presentation
- Premium dark navy + gold visual theme with a colorful, clear dashboard.
- Keep the SYSY FAMILY brand name and a polished house/window logo.
- Contact details on generated PDFs: +230 5890 9358 and Shubunkarsutradhar@gmail.com.
- Do not show a business location/address on PDFs.
- Full UI language switch: English and Bangla.
- Back navigation, Save, Edit, Add, Delete with confirmation where appropriate.

## Dashboard and customer management
- Dashboard summaries: total customers, jobs, sales, paid, outstanding balance, ongoing/completed/payment-pending work.
- Search by customer name, phone, job site, and quotation number.
- Customer/job history links measurements, quotations, payments, dates, paid amounts, and balances.
- Prevent duplicate payment records.

## Measurement spreadsheet
- Full-screen, wide, Excel-like editable measurement table; pressing Edit should open a genuinely usable full-screen table, not a small form.
- Columns in this order: .REF, WIDTH, HEIGHT, TOTAL(M), PARSENT (%), RATE, TOTAL(RS).
- Width/height entered in millimetres; area is calculated in square metres (m²), not square feet.
- Percentage field is entered per row and calculates that row's percentage amount from its row total; show overall work progress and progress billing against the overall bill as separate values to avoid confusing row percentages with whole-bill progress.
- Support add/edit/delete rows, automatic totals, and PDF export with all rows.

## Billing and PDFs
- Currency: Mauritian rupees (MUR / Rs).
- Calculate total, advance, paid, and balance; support 20%, 50%, 70%, 80%, and 100% progress billing.
- Generate professional quotation, invoice, measurement sheet, payment receipt, and job summary PDFs.
- PDFs should show company logo/name, phone and email, customer/job details, measurement rows, percentages, rates, totals, advance, paid, balance, and progress amount.
- Use polished house, aluminium door/window, shower-glass, balcony-glass and glass-balustrade imagery when suitable; images must not obscure or replace real customer data or calculations.
- Professional service description: “We specialize in professional aluminium door and window installation, precise measurements, expert fixing and neat finishing. We are committed to quality workmanship, reliable service and lasting results.”
- Services to display: aluminium doors and windows; sliding/folding doors; glass partitions; shower enclosures; balcony glass and glass balustrades; repair, maintenance and fixing.

## Data safety and build
- Preserve V63/V62 restore rollback/undo safeguard, checksum and restore validation, backup/restore, and advance-date fallback behavior.
- Test data persistence, editing, deletion confirmation, PDF calculations, percentage calculations, and English/Bangla switching before considering the update ready.
- This file records approved requirements only; it does not mean the app code or IPA build is complete.
