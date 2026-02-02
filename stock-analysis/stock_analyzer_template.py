"""
通用上市公司结构化分析工具
基于Microsoft案例验证的方法论，适用于任何上市公司分析
"""

import yfinance as yf
import pandas as pd
import numpy as np
from datetime import datetime


class StockAnalyzer:
    def __init__(self, ticker):
        """
        初始化股票分析器
        :param ticker: 股票代码 (如 'MSFT', 'AAPL', 'GOOGL')
        """
        self.ticker = ticker
        self.stock = yf.Ticker(ticker)
        self.info = self.stock.info
        
        # 获取财务数据
        self.financials = self.stock.financials.T if not self.stock.financials.empty else None
        self.balance_sheet = self.stock.balance_sheet.T if not self.stock.balance_sheet.empty else None
        self.cash_flow = self.stock.cashflow.T if not self.stock.cashflow.empty else None
        
        if self.financials is not None:
            self.financials = self.financials.sort_index(ascending=True)
        if self.balance_sheet is not None:
            self.balance_sheet = self.balance_sheet.sort_index(ascending=True)
        if self.cash_flow is not None:
            self.cash_flow = self.cash_flow.sort_index(ascending=True)

    def get_basic_info(self):
        """获取公司基本信息"""
        hist = self.stock.history(period='1d')
        current_price = 0
        if not hist.empty:
            current_price = hist['Close'].iloc[-1]
        
        basic_info = {
            'company_name': self.info.get('longName', self.ticker),
            'sector': self.info.get('sector', 'N/A'),
            'industry': self.info.get('industry', 'N/A'),
            'market_cap': self.info.get('marketCap', 0),
            'current_price': current_price,
            'employees': self.info.get('fullTimeEmployees', 'N/A')
        }
        return basic_info

    def analyze_profitability(self):
        """盈利能力分析"""
        if self.financials is None:
            return {}
        
        # 提取关键数据
        revenue = self.financials['Total Revenue'] if 'Total Revenue' in self.financials.columns else pd.Series(dtype=float)
        net_income = self.financials['Net Income'] if 'Net Income' in self.financials.columns else pd.Series(dtype=float)
        gross_profit = self.financials['Gross Profit'] if 'Gross Profit' in self.financials.columns else pd.Series(dtype=float)
        
        profitability_metrics = {}
        
        # 计算利润率
        if not revenue.empty and not net_income.empty:
            net_margin = (net_income / revenue) * 100
            profitability_metrics['net_margin'] = net_margin.dropna()
        
        if not revenue.empty and not gross_profit.empty:
            gross_margin = (gross_profit / revenue) * 100
            profitability_metrics['gross_margin'] = gross_margin.dropna()
        
        # 收入和净利润趋势
        profitability_metrics['revenue_trend'] = revenue
        profitability_metrics['net_income_trend'] = net_income
        
        return profitability_metrics

    def analyze_cash_flow(self):
        """现金流分析"""
        if self.cash_flow is None:
            return {}
        
        cash_flow_metrics = {}
        
        # 获取现金流数据
        if 'Free Cash Flow' in self.cash_flow.columns:
            cash_flow_metrics['free_cash_flow'] = self.cash_flow['Free Cash Flow']
        
        if 'Operating Cash Flow' in self.cash_flow.columns:
            cash_flow_metrics['operating_cash_flow'] = self.cash_flow['Operating Cash Flow']
        
        if 'Capital Expenditure' in self.cash_flow.columns:
            cash_flow_metrics['capex'] = self.cash_flow['Capital Expenditure']
        
        # 计算关键比率
        fcf = cash_flow_metrics.get('free_cash_flow', pd.Series(dtype=float))
        net_income = self.financials['Net Income'] if self.financials is not None and 'Net Income' in self.financials.columns else pd.Series(dtype=float)
        
        if not fcf.empty and not net_income.empty:
            # 找到匹配的年份
            common_years = fcf.index.intersection(net_income.index)
            if len(common_years) > 0:
                fcf_net_income_ratio = (fcf[common_years] / net_income[common_years]) * 100
                cash_flow_metrics['fcf_net_income_ratio'] = fcf_net_income_ratio
        
        return cash_flow_metrics

    def analyze_balance_sheet(self):
        """资产负债表分析"""
        if self.balance_sheet is None:
            return {}
        
        balance_metrics = {}
        
        # 获取关键数据
        if 'Cash And Cash Equivalents' in self.balance_sheet.columns:
            balance_metrics['cash_and_equivalents'] = self.balance_sheet['Cash And Cash Equivalents']
        
        if 'Cash Cash Equivalents And Short Term Investments' in self.balance_sheet.columns:
            balance_metrics['cash_short_investments'] = self.balance_sheet['Cash Cash Equivalents And Short Term Investments']
        
        if 'Total Debt' in self.balance_sheet.columns:
            balance_metrics['total_debt'] = self.balance_sheet['Total Debt']
        
        if 'Total Assets' in self.balance_sheet.columns:
            balance_metrics['total_assets'] = self.balance_sheet['Total Assets']
        
        if 'Total Liabilities Net Minority Interest' in self.balance_sheet.columns:
            balance_metrics['total_liabilities'] = self.balance_sheet['Total Liabilities Net Minority Interest']
        
        if 'Stockholders Equity' in self.balance_sheet.columns:
            balance_metrics['shareholders_equity'] = self.balance_sheet['Stockholders Equity']
        
        # 计算净现金
        cash_st = balance_metrics.get('cash_short_investments', pd.Series(dtype=float))
        debt = balance_metrics.get('total_debt', pd.Series(dtype=float))
        
        if not cash_st.empty and not debt.empty:
            common_years = cash_st.index.intersection(debt.index)
            if len(common_years) > 0:
                net_cash = cash_st[common_years] - debt[common_years]
                balance_metrics['net_cash'] = net_cash
        
        return balance_metrics

    def analyze_valuation(self):
        """估值分析"""
        valuation = {
            'market_cap': self.info.get('marketCap', 0),
            'trailing_pe': self.info.get('trailingPE', 'N/A'),
            'forward_pe': self.info.get('forwardPE', 'N/A'),
            'peg_ratio': self.info.get('pegRatio', 'N/A'),
            'price_to_book': self.info.get('priceToBook', 'N/A'),
            'ev_to_revenue': self.info.get('enterpriseToRevenue', 'N/A'),
            'ev_to_ebitda': self.info.get('enterpriseToEbitda', 'N/A')
        }
        return valuation

    def generate_analysis_report(self):
        """生成综合分析报告"""
        basic_info = self.get_basic_info()
        profitability = self.analyze_profitability()
        cash_flow = self.analyze_cash_flow()
        balance_sheet = self.analyze_balance_sheet()
        valuation = self.analyze_valuation()
        
        report = {
            'basic_info': basic_info,
            'profitability': profitability,
            'cash_flow': cash_flow,
            'balance_sheet': balance_sheet,
            'valuation': valuation,
            'analysis_date': datetime.now().strftime('%Y-%m-%d')
        }
        
        return report

    def print_formatted_report(self):
        """打印格式化的分析报告"""
        report = self.generate_analysis_report()
        
        print("="*60)
        print(f"上市公司结构化分析报告 - {report['basic_info']['company_name']} ({self.ticker})")
        print("="*60)
        print(f"分析日期: {report['analysis_date']}")
        print(f"公司名称: {report['basic_info']['company_name']}")
        print(f"行业: {report['basic_info']['sector']} - {report['basic_info']['industry']}")
        print(f"市值: ${report['basic_info']['market_cap']/1e9:.2f}B" if report['basic_info']['market_cap'] > 0 else f"市值: N/A")
        print(f"当前股价: ${report['basic_info']['current_price']:.2f}")
        print()
        
        # 盈利能力分析
        print("【盈利能力分析】")
        if 'revenue_trend' in report['profitability'] and not report['profitability']['revenue_trend'].empty:
            print("收入趋势:")
            for year, value in report['profitability']['revenue_trend'].tail(4).items():
                print(f"  {year.strftime('%Y')}: ${value/1e9:.2f}B")
        
        if 'net_income_trend' in report['profitability'] and not report['profitability']['net_income_trend'].empty:
            print("净利润趋势:")
            for year, value in report['profitability']['net_income_trend'].tail(4).items():
                print(f"  {year.strftime('%Y')}: ${value/1e9:.2f}B")
        
        if 'gross_margin' in report['profitability'] and not report['profitability']['gross_margin'].empty:
            print("毛利率趋势:")
            for year, value in report['profitability']['gross_margin'].tail(4).items():
                print(f"  {year.strftime('%Y')}: {value:.2f}%")
        
        if 'net_margin' in report['profitability'] and not report['profitability']['net_margin'].empty:
            print("净利率趋势:")
            for year, value in report['profitability']['net_margin'].tail(4).items():
                print(f"  {year.strftime('%Y')}: {value:.2f}%")
        print()
        
        # 现金流分析
        print("【现金流分析】")
        if 'free_cash_flow' in report['cash_flow'] and not report['cash_flow']['free_cash_flow'].empty:
            print("自由现金流(Free Cash Flow):")
            for year, value in report['cash_flow']['free_cash_flow'].tail(4).items():
                print(f"  {year.strftime('%Y')}: ${value/1e9:.2f}B")
        
        if 'capex' in report['cash_flow'] and not report['cash_flow']['capex'].empty:
            print("资本开支(CapEx) - 注意：通常为负值表示现金流出:")
            for year, value in report['cash_flow']['capex'].tail(4).items():
                print(f"  {year.strftime('%Y')}: ${value/1e9:.2f}B")
        
        if 'fcf_net_income_ratio' in report['cash_flow'] and not report['cash_flow']['fcf_net_income_ratio'].empty:
            print("自由现金流转化率(Free Cash Flow / Net Income):")
            for year, value in report['cash_flow']['fcf_net_income_ratio'].tail(4).items():
                print(f"  {year.strftime('%Y')}: {value:.2f}%")
        print()
        
        # 资产负债表分析
        print("【资产负债表分析】")
        if 'net_cash' in report['balance_sheet'] and not report['balance_sheet']['net_cash'].empty:
            print("净现金状况 (现金及短期投资 - 总债务):")
            for year, value in report['balance_sheet']['net_cash'].tail(4).items():
                status = "净现金" if value > 0 else "净负债"
                print(f"  {year.strftime('%Y')}: ${value/1e9:.2f}B ({status})")
        
        if 'total_debt' in report['balance_sheet'] and not report['balance_sheet']['total_debt'].empty:
            print("总债务:")
            for year, value in report['balance_sheet']['total_debt'].tail(4).items():
                print(f"  {year.strftime('%Y')}: ${value/1e9:.2f}B")
        print()
        
        # 估值分析
        print("【估值分析】")
        print(f"市值: ${report['valuation']['market_cap']/1e12:.2f}T" if report['valuation']['market_cap'] > 0 else "市值: N/A")
        print(f"滚动市盈率(P/E): {report['valuation']['trailing_pe']}")
        print(f"前瞻市盈率(Forward P/E): {report['valuation']['forward_pe']}")
        print(f"PEG比率: {report['valuation']['peg_ratio']}")
        print(f"市净率(P/B): {report['valuation']['price_to_book']}")
        print(f"EV/Revenue: {report['valuation']['ev_to_revenue']}")
        print(f"EV/EBITDA: {report['valuation']['ev_to_ebitda']}")
        print()
        
        print("="*60)
        print("分析完成")
        print("="*60)


def analyze_stock(ticker):
    """
    便捷函数：直接分析指定股票
    :param ticker: 股票代码
    """
    analyzer = StockAnalyzer(ticker)
    analyzer.print_formatted_report()


# 示例使用
if __name__ == "__main__":
    # 示例：分析微软 (MSFT)
    print("正在分析微软 (MSFT)...")
    analyze_stock("MSFT")