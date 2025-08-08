# Regulatory Update Summarizer

An AI-powered system that automatically monitors regulatory updates, summarizes them using advanced language models, and provides intelligent notifications through various channels.

## Features

- **Automated Monitoring**: Continuously monitors regulatory websites and feeds
- **AI Summarization**: Uses large language models to create concise, relevant summaries
- **Smart Notifications**: Delivers updates through multiple channels (email, Slack, etc.)
- **Interactive Interface**: Web-based dashboard built with Gradio
- **Data Storage**: Efficient storage and retrieval using TiDB
- **Workflow Automation**: N8N-powered workflows for seamless integration

## Architecture

- **Frontend**: Gradio-based web application
- **Backend**: Python-based processing engine
- **Database**: TiDB for scalable data storage
- **Automation**: N8N workflow engine
- **AI/ML**: Integration with leading language models

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/nehaneet/regulatory-update-summarizer.git
   cd regulatory-update-summarizer
   ```

2. Set up the Gradio application:
   ```bash
   cd gradio-app
   pip install -r requirements.txt
   python app.py
   ```

3. Configure the database:
   ```bash
   # Set up TiDB connection and run schema
   mysql -h <your-tidb-host> -u <username> -p < tidb/schema.sql
   ```

## Project Structure

```
regulatory-update-summarizer/
├── README.md
├── LICENSE
├── .gitignore
├── gradio-app/
│   ├── app.py
│   └── requirements.txt
├── tidb/
│   └── schema.sql
├── n8n-workflow/
│   └── docs.md
└── assets/
    └── screenshots/
```

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please open an issue on GitHub.
