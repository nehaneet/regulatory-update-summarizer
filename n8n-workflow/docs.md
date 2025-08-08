# N8N Workflow Documentation

This directory contains documentation and configuration for N8N workflow automation for the Regulatory Update Summarizer.

## Overview

N8N (n8n.io) is used to automate the regulatory update monitoring and processing workflow. The workflows handle:

- **Data Collection**: Automated scraping of regulatory websites
- **Content Processing**: Text extraction and cleaning
- **AI Summarization**: Integration with language models
- **Notification Delivery**: Multi-channel alert distribution
- **Database Operations**: Storing and updating regulatory data

## Workflow Components

### 1. Regulatory Source Monitor

**Purpose**: Monitors regulatory websites for new updates

**Schedule**: Runs every 6 hours (configurable)

**Nodes**:
- **Cron Trigger**: Schedules execution
- **HTTP Request**: Fetches content from regulatory sources
- **HTML Extract**: Parses and extracts relevant content
- **Set Node**: Structures data for processing
- **Database Insert**: Stores raw updates in TiDB

**Configuration**:
```json
{
  "cronExpression": "0 */6 * * *",
  "sources": [
    {
      "name": "SEC Press Releases",
      "url": "https://www.sec.gov/news/pressreleases",
      "selector": ".release-item"
    },
    {
      "name": "FDA Announcements",
      "url": "https://www.fda.gov/news-events/fda-newsroom/press-announcements",
      "selector": ".node-press-announcement"
    }
  ]
}
```

### 2. AI Summarization Pipeline

**Purpose**: Generates AI-powered summaries of regulatory updates

**Trigger**: Activated when new updates are detected

**Nodes**:
- **Database Trigger**: Monitors for new regulatory updates
- **Text Preprocessing**: Cleans and prepares content
- **OpenAI/Claude API**: Generates summaries
- **Content Analysis**: Extracts key points and action items
- **Database Update**: Stores AI-generated summaries

**AI Prompt Template**:
```
Analyze the following regulatory update and provide:

1. Executive Summary (2-3 sentences)
2. Key Points (bullet list)
3. Affected Industries/Sectors
4. Compliance Timeline
5. Required Actions
6. Impact Assessment (Low/Medium/High)

Regulatory Update:
{{content}}
```

### 3. Notification Distribution

**Purpose**: Sends notifications through multiple channels

**Trigger**: New high-priority updates or scheduled digest

**Channels**:
- **Email**: SMTP integration for email notifications
- **Slack**: Webhook integration for team alerts
- **Webhook**: Custom integrations for external systems
- **SMS**: Twilio integration for critical alerts

**Nodes**:
- **Priority Filter**: Routes based on update priority
- **Template Engine**: Formats notification content
- **Multi-Channel Send**: Distributes to configured channels
- **Delivery Tracking**: Records notification status

### 4. Data Quality & Deduplication

**Purpose**: Ensures data quality and prevents duplicates

**Features**:
- **Content Hashing**: SHA-256 hash for duplicate detection
- **Similarity Check**: NLP-based content comparison
- **Source Validation**: Verifies source authenticity
- **Data Enrichment**: Adds metadata and categorization

## Setup Instructions

### Prerequisites

1. **N8N Installation**:
   ```bash
   npm install -g n8n
   # OR
   docker run -d --name n8n -p 5678:5678 n8nio/n8n
   ```

2. **Environment Variables**:
   ```bash
   export N8N_BASIC_AUTH_ACTIVE=true
   export N8N_BASIC_AUTH_USER=admin
   export N8N_BASIC_AUTH_PASSWORD=your_secure_password
   export WEBHOOK_URL=https://your-domain.com/webhook/n8n
   ```

3. **Database Connection**:
   ```bash
   export DB_TYPE=mysql
   export DB_MYSQLDB_HOST=your-tidb-host
   export DB_MYSQLDB_PORT=4000
   export DB_MYSQLDB_DATABASE=regulatory_updates
   export DB_MYSQLDB_USER=your_username
   export DB_MYSQLDB_PASSWORD=your_password
   ```

### Workflow Import

1. **Access N8N Interface**: Navigate to `http://localhost:5678`
2. **Import Workflows**: Use the provided JSON files
3. **Configure Credentials**: Set up API keys and database connections
4. **Test Workflows**: Run test executions to verify setup

### Required Credentials

#### OpenAI API
```json
{
  "name": "OpenAI API",
  "type": "openAi",
  "data": {
    "apiKey": "your-openai-api-key"
  }
}
```

#### TiDB Database
```json
{
  "name": "TiDB Connection",
  "type": "mysql",
  "data": {
    "host": "your-tidb-host",
    "port": 4000,
    "database": "regulatory_updates",
    "user": "your-username",
    "password": "your-password"
  }
}
```

#### Email SMTP
```json
{
  "name": "Email SMTP",
  "type": "smtp",
  "data": {
    "host": "smtp.gmail.com",
    "port": 587,
    "secure": false,
    "user": "your-email@gmail.com",
    "password": "your-app-password"
  }
}
```

#### Slack Webhook
```json
{
  "name": "Slack Webhook",
  "type": "webhook",
  "data": {
    "url": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
  }
}
```

## Workflow Files Structure

```
n8n-workflow/
├── docs.md                     # This documentation file
├── regulatory-monitor.json     # Main monitoring workflow
├── ai-summarization.json      # AI processing workflow
├── notification-system.json   # Alert distribution workflow
├── data-quality.json          # Data cleaning workflow
└── templates/
    ├── email-template.html     # Email notification template
    ├── slack-template.json     # Slack message template
    └── summary-prompt.txt      # AI summarization prompt
```

## Monitoring & Maintenance

### Workflow Monitoring

1. **Execution History**: Monitor workflow runs in N8N interface
2. **Error Handling**: Set up error notification workflows
3. **Performance Metrics**: Track execution times and success rates
4. **Resource Usage**: Monitor CPU and memory consumption

### Scheduled Maintenance

1. **Weekly**: Review failed executions and error logs
2. **Monthly**: Update source configurations and selectors
3. **Quarterly**: Optimize workflows and update AI prompts
4. **Annually**: Review and update security credentials

### Troubleshooting

#### Common Issues

1. **Source Website Changes**:
   - Update CSS selectors in HTML Extract nodes
   - Verify source URLs are still valid
   - Adjust rate limiting if blocked

2. **AI API Limits**:
   - Implement retry logic with exponential backoff
   - Use multiple API providers for failover
   - Monitor usage quotas and billing

3. **Database Connectivity**:
   - Check TiDB connection credentials
   - Verify network connectivity and firewall rules
   - Monitor database performance and storage

4. **Notification Delivery**:
   - Test SMTP and webhook configurations
   - Check spam filters and delivery rates
   - Verify recipient lists and permissions

### Performance Optimization

1. **Parallel Processing**: Use Split In Batches nodes for large datasets
2. **Caching**: Implement Redis caching for frequently accessed data
3. **Rate Limiting**: Respect source website rate limits
4. **Resource Management**: Configure appropriate timeout values

## Security Considerations

1. **Credential Management**: Use N8N's encrypted credential storage
2. **Network Security**: Use VPN or private networks for database access
3. **API Key Rotation**: Regularly rotate API keys and passwords
4. **Access Control**: Implement proper user authentication and authorization
5. **Data Privacy**: Ensure compliance with data protection regulations

## Integration with Other Components

### Gradio Application
- **Webhook Integration**: N8N can trigger Gradio app functions
- **Shared Database**: Both systems use the same TiDB instance
- **API Endpoints**: Gradio can trigger N8N workflows via webhooks

### TiDB Database
- **Connection Pool**: Configure appropriate connection limits
- **Query Optimization**: Use indexes for frequently accessed columns
- **Data Retention**: Implement automatic cleanup of old data

## Development & Testing

### Local Development

1. **Development Environment**:
   ```bash
   docker-compose up -d  # Start N8N and TiDB locally
   ```

2. **Test Workflows**: Create test versions with limited scope
3. **Mock Data**: Use test data for development and debugging
4. **Version Control**: Export workflows to JSON for version tracking

### Production Deployment

1. **Environment Separation**: Use different N8N instances for dev/prod
2. **Backup Strategy**: Regular workflow and data backups
3. **Monitoring**: Set up comprehensive monitoring and alerting
4. **Documentation**: Keep workflow documentation up to date

## Support & Resources

- **N8N Documentation**: https://docs.n8n.io/
- **Community Forum**: https://community.n8n.io/
- **Workflow Templates**: https://n8n.io/workflows/
- **API References**: Regulatory source API documentation

## Contributing

When contributing to N8N workflows:

1. **Test Thoroughly**: Ensure workflows work in different scenarios
2. **Document Changes**: Update this documentation file
3. **Follow Standards**: Use consistent naming and organization
4. **Security Review**: Ensure no credentials are exposed in exports
5. **Performance Impact**: Consider resource usage implications
