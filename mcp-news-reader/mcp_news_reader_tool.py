#!/usr/bin/env python3
"""
MCP News Reader Tool - Uses the official mcporter CLI to access news sources
"""
import subprocess
import json
import sys
import os
from datetime import datetime


class MCPOfficialNewsReader:
    """
    Uses the official mcporter tool to access MCP news sources
    This connects to the real Model Context Protocol service
    """
    
    def __init__(self):
        self.mcporter_dir = "/home/chengzh/clawd/tools/mcporter"
        self.ensure_mcporter_available()
    
    def ensure_mcporter_available(self):
        """Ensure mcporter is available and newsnow server is configured"""
        if not os.path.exists(self.mcporter_dir):
            raise Exception(f"mcporter directory not found: {self.mcporter_dir}")
        
        # Verify newsnow server is configured
        try:
            result = subprocess.run([
                "npx", "tsx", "src/cli.ts", "list", "newsnow"
            ], cwd=self.mcporter_dir, capture_output=True, text=True, timeout=30)
            
            if result.returncode != 0:
                # Add the server if not found
                subprocess.run([
                    "npx", "tsx", "src/cli.ts", "config", "add", "newsnow", "https://newsnow-mcp.zhaikr.com/sse"
                ], cwd=self.mcporter_dir, capture_output=True, text=True, timeout=30)
        except Exception as e:
            print(f"Warning: Could not verify newsnow server: {e}")
    
    def list_news_sources(self, limit=20):
        """List available news sources"""
        print(f"🔍 Retrieving news sources (limit: {limit})...")
        
        try:
            result = subprocess.run([
                "npx", "tsx", "src/cli.ts", "call", "newsnow.newsnow_list_sources", f"limit={limit}"
            ], cwd=self.mcporter_dir, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print(result.stdout)
                return result.stdout
            else:
                print(f"❌ Error listing sources: {result.stderr}")
                return None
        except Exception as e:
            print(f"❌ Exception listing sources: {e}")
            return None
    
    def get_latest_news(self, source_id, limit=10):
        """Get latest news from a specific source"""
        print(f"📰 Fetching latest news from '{source_id}' (limit: {limit})...")
        
        try:
            result = subprocess.run([
                "npx", "tsx", "src/cli.ts", "call", "newsnow.newsnow_get_latest_news", 
                f"id={source_id}", f"limit={limit}"
            ], cwd=self.mcporter_dir, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print(result.stdout)
                return result.stdout
            else:
                print(f"❌ Error fetching news from {source_id}: {result.stderr}")
                return None
        except Exception as e:
            print(f"❌ Exception fetching news from {source_id}: {e}")
            return None
    
    def get_source_details(self, source_id):
        """Get details about a specific source"""
        print(f"🔍 Getting details for source '{source_id}'...")
        
        try:
            result = subprocess.run([
                "npx", "tsx", "src/cli.ts", "call", "newsnow.newsnow_get_source", 
                f"id={source_id}"
            ], cwd=self.mcporter_dir, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print(result.stdout)
                return result.stdout
            else:
                print(f"❌ Error getting source details: {result.stderr}")
                return None
        except Exception as e:
            print(f"❌ Exception getting source details: {e}")
            return None
    
    def read_top_news(self, sources=['weibo', 'zhihu', 'hackernews'], limit=5):
        """Read top news from multiple popular sources"""
        print(f"🚀 MCP Official News Reader")
        print(f"📡 Connected to: https://newsnow-mcp.zhaikr.com/sse")
        print(f"📅 Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
        
        all_news = {}
        
        for source in sources:
            print(f"\nFetching from {source.upper()}...")
            print("-" * 40)
            news_data = self.get_latest_news(source, limit)
            if news_data:
                all_news[source] = news_data
        
        return all_news


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python mcp_news_reader_tool.py sources [limit]     # List news sources")
        print("  python mcp_news_reader_tool.py news <source> [limit]  # Get news from source")
        print("  python mcp_news_reader_tool.py top [limit]         # Get top news from multiple sources")
        print("")
        print("Examples:")
        print("  python mcp_news_reader_tool.py sources 10          # List 10 news sources")
        print("  python mcp_news_reader_tool.py news weibo 5        # Get 5 latest Weibo trends")
        print("  python mcp_news_reader_tool.py top                 # Get top news from major sources")
        return
    
    reader = MCPOfficialNewsReader()
    command = sys.argv[1]
    
    if command == "sources":
        limit = int(sys.argv[2]) if len(sys.argv) > 2 else 20
        reader.list_news_sources(limit)
    
    elif command == "news":
        if len(sys.argv) < 3:
            print("Please specify a source ID")
            return
        source_id = sys.argv[2]
        limit = int(sys.argv[3]) if len(sys.argv) > 3 else 10
        reader.get_latest_news(source_id, limit)
    
    elif command == "top":
        limit = int(sys.argv[2]) if len(sys.argv) > 2 else 5
        sources = ['weibo', 'zhihu', 'hackernews', 'github-trending-today']
        reader.read_top_news(sources, limit)
    
    else:
        print(f"Unknown command: {command}")
        print("Use 'sources', 'news', or 'top'")


if __name__ == "__main__":
    main()