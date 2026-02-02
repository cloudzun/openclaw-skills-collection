#!/usr/bin/env python3
"""
MCP News Reader - Reads news from MCP (Messaging Control Protocol) sources
"""
import requests
import json
import sys
import time
from urllib.parse import urljoin
from datetime import datetime


class MCPNewsReader:
    def __init__(self, base_url, timeout=30):
        self.base_url = base_url
        self.timeout = timeout
        self.session_id = None
        
    def connect_and_read_news(self, duration=60):
        """
        Connect to MCP endpoint and read news in a single continuous connection.
        This is necessary because session IDs expire when the initial connection closes.
        
        Args:
            duration: How long to listen for events (in seconds)
        """
        print(f"🚀 Starting MCP News Reader")
        print(f"🌐 Endpoint: {self.base_url}")
        print(f"⏱️  Duration: {duration}s")
        print("-" * 50)
        
        try:
            print("🔍 Connecting to MCP endpoint...")
            response = requests.get(self.base_url, stream=True, timeout=self.timeout)
            
            if response.status_code != 200:
                print(f"❌ Connection failed with status: {response.status_code}")
                return False
            
            print("📡 Connected. Waiting for session initialization...")
            
            start_time = time.time()
            event_count = 0
            
            for line in response.iter_lines(decode_unicode=True):
                current_time = time.time()
                
                # Stop if duration has passed
                if current_time - start_time > duration:
                    print(f"\n⏱️  Duration ({duration}s) reached, stopping...")
                    break
                
                if line.strip():
                    if line.startswith("event: endpoint"):
                        print("✅ Received endpoint event")
                    elif line.startswith("data:"):
                        data = line[5:].strip()
                        
                        # Check if this is the session endpoint data
                        if data.startswith("/sse/message?sessionId="):
                            self.session_id = data.split("=")[1]
                            print(f"🔑 Session established: {self.session_id[:16]}...")
                            print("📰 Now listening for news events...\n")
                        else:
                            # This is likely a news event
                            try:
                                # Try to parse as JSON (news content)
                                parsed_data = json.loads(data)
                                event_count += 1
                                self._print_news_event(parsed_data, event_count)
                            except json.JSONDecodeError:
                                # Raw data that's not JSON
                                print(f"📝 Raw Event #{event_count}: {data}")
                    elif line.startswith("event:"):
                        event_type = line[7:].strip()
                        if event_type != "endpoint":  # Don't print endpoint events again
                            print(f"🏷️  Event type: {event_type}")
                    elif line.startswith("id:"):
                        event_id = line[3:].strip()
                        print(f"🆔 Event ID: {event_id}")
                    elif line.startswith("retry:"):
                        retry_time = line[7:].strip()
                        print(f"🔄 Retry after: {retry_time}ms")
                    else:
                        # Just a message line - might be news content
                        if self.session_id:  # Only print as news if session is established
                            print(f"💬 Message: {line}")
                        
        except requests.exceptions.Timeout:
            print("⏰ Connection timed out")
        except KeyboardInterrupt:
            print("\n⏹️  User interrupted")
        except Exception as e:
            print(f"❌ Error reading news stream: {e}")
            import traceback
            traceback.print_exc()
        
        print(f"\n✅ News reading completed. Processed {event_count} events.")
        return True
    
    def _print_news_event(self, data, event_num):
        """Format and print a news event nicely."""
        print(f"🗞️  News Event #{event_num} - {datetime.now().strftime('%H:%M:%S')}")
        
        if isinstance(data, dict):
            # Common news fields
            title = data.get('title', data.get('headline', ''))
            content = data.get('content', data.get('summary', data.get('text', '')))
            source = data.get('source', data.get('provider', 'Unknown'))
            timestamp = data.get('timestamp', data.get('date', ''))
            url = data.get('url', data.get('link', ''))
            
            if title:
                print(f"   📌 Title: {title}")
            if source:
                print(f"   🏢 Source: {source}")
            if timestamp:
                print(f"   🕒 Time: {timestamp}")
            if content:
                print(f"   📝 Content: {content[:200]}{'...' if len(content) > 200 else ''}")
            if url:
                print(f"   🔗 URL: {url}")
        else:
            print(f"   📄 Data: {data}")
        
        print()  # Empty line for readability


def main():
    if len(sys.argv) < 2:
        print("Usage: python mcp_news_reader.py <mcp_url> [duration_seconds]")
        print("Example: python mcp_news_reader.py https://newsnow-mcp.zhaikr.com/sse 60")
        sys.exit(1)
    
    mcp_url = sys.argv[1]
    duration = int(sys.argv[2]) if len(sys.argv) > 2 else 60
    
    reader = MCPNewsReader(mcp_url, timeout=30)
    reader.connect_and_read_news(duration)


if __name__ == "__main__":
    main()