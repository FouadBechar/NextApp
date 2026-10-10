import { Body, Container, Head, Heading, Html, Preview, Section, Text, Link } from '@react-email/components';
import * as React from 'react';

interface ExportEmailProps {
  filename: string;
  dashboardUrl?: string;
  downloadUrl?: string | null;
}

export const ExportEmail = ({ filename, dashboardUrl = 'https://fbweb.vercel.app/dashboard', downloadUrl = null }: ExportEmailProps) => {
  return (
    <Html>
      <Head />
      <Preview>Your data export is ready</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>Your data export is ready</Heading>
          <Text style={text}>We've generated an export of your account data as <strong>{filename}</strong>.</Text>
          <Text style={text}>For security, the export is attached to this email (when possible). You can also visit your dashboard to manage your account.</Text>
          {downloadUrl && (
            <Text style={text}>You can download the export using the link below. The link expires after a short period for your security.</Text>
          )}
          <Section style={buttonContainer}>
            <Link style={button} href={dashboardUrl}>Open Dashboard</Link>
          </Section>
          {downloadUrl && (
            <Section style={buttonContainer}>
              <Link style={button} href={downloadUrl} target="_blank" rel="noopener noreferrer">Download export</Link>
            </Section>
          )}
        </Container>
      </Body>
    </Html>
  );
};

const main = { backgroundColor: '#f6f9fc', fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif' };
const container = { margin: '0 auto', padding: '20px 0 48px', maxWidth: '580px' };
const h1 = { color: '#333', fontSize: '24px', fontWeight: '600', lineHeight: '1.25', marginBottom: '24px', textAlign: 'center' as const };
const text = { color: '#555', fontSize: '16px', lineHeight: '1.5', marginBottom: '24px' };
const buttonContainer = { textAlign: 'center' as const, marginTop: '32px' };
const button = { backgroundColor: '#3b82f6', borderRadius: '4px', color: '#fff', display: 'inline-block', fontSize: '16px', fontWeight: '600', padding: '12px 24px', textDecoration: 'none' };

export default ExportEmail;
