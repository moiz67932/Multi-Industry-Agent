# Dashboard Industry-Aware Branding — Implementation Guide

This document describes how to make the Next.js dashboard industry-aware
so it shows the correct branding, labels, and accent colors for each
industry profile (dental, med_spa, etc.).

## Variables Provided by the Backend

The `industry_type` field is stored in `agent_settings.config_json` for each
clinic. When the dashboard loads clinic data, it should read:

```json
{
  "industry_type": "dental" | "med_spa"
}
```

This comes from the `config_json` column in the `agent_settings` table.
For dental clinics, `industry_type` is either `"dental"` or absent (default).
For spa clinics, `industry_type` is `"med_spa"`.

## Step 1: Create `src/utils/industryConfig.ts`

```typescript
export const INDUSTRY_CONFIG = {
  dental: {
    brandName: 'Ortho AI',
    tagline: 'Clinic Dashboard',
    appointmentLabel: 'Appointment',
    patientLabel: 'Patient',
    reasonLabel: 'Treatment',
    accentColor: '#0D9488',
  },
  med_spa: {
    brandName: 'Aura AI',
    tagline: 'Spa Dashboard',
    appointmentLabel: 'Booking',
    patientLabel: 'Guest',
    reasonLabel: 'Treatment',
    accentColor: '#9333EA', // soft purple for spa aesthetic
  },
} as const;

export type IndustryType = keyof typeof INDUSTRY_CONFIG;

export function getIndustryConfig(industry_type?: string) {
  const key = (industry_type || 'dental') as IndustryType;
  return INDUSTRY_CONFIG[key] || INDUSTRY_CONFIG['dental'];
}
```

## Step 2: Add `industry_type` to Clinic Type

In `useClinic.tsx` (or wherever the Clinic type is defined), add:

```typescript
interface Clinic {
  // ... existing fields ...
  industry_type?: string;
}
```

Parse `industry_type` from `agent_settings.config_json` when loading
clinic data. If using the mock clinic object, add:

```typescript
const mockClinic: Clinic = {
  // ... existing fields ...
  industry_type: 'dental', // or read from env/config
};
```

## Step 3: Update `DashboardLayout.tsx`

```typescript
import { getIndustryConfig } from '@/utils/industryConfig';

// Inside the component:
const clinic = useClinic();
const industryConfig = getIndustryConfig(clinic?.industry_type);

// Replace hardcoded "Ortho AI" with:
<h1>{industryConfig.brandName}</h1>
<p>{industryConfig.tagline}</p>

// Optionally use industryConfig.accentColor for theming:
<div style={{ borderColor: industryConfig.accentColor }}>
```

## Step 4: Update `AppointmentsTable.tsx`

Replace hardcoded column headers:

```typescript
const industryConfig = getIndustryConfig(clinic?.industry_type);

// Instead of "Patient" column header:
<th>{industryConfig.patientLabel}</th>

// Instead of "Treatment" column header:
<th>{industryConfig.reasonLabel}</th>
```

## Step 5: Update KPI Cards

Replace "Today's Appointments" with dynamic label:

```typescript
const industryConfig = getIndustryConfig(clinic?.industry_type);

// Instead of "Today's Appointments":
<Card title={`Today's ${industryConfig.appointmentLabel}s`} />
```

## Result

| Field              | Dental (default)          | Med Spa                    |
|--------------------|---------------------------|----------------------------|
| Brand Name         | Ortho AI                  | Aura AI                    |
| Tagline            | Clinic Dashboard          | Spa Dashboard              |
| Appointment Label  | Appointment               | Booking                    |
| Patient Label      | Patient                   | Guest                      |
| Reason Label       | Treatment                 | Treatment                  |
| Accent Color       | #0D9488 (teal)            | #9333EA (purple)           |

The dental dashboard remains **completely unchanged** — all new branding
only activates when `industry_type === 'med_spa'`.
