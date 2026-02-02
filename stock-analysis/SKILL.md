# 上市公司结构化分析技能 (Stock Analysis)

## 技能概述
定义了一套标准化的上市公司深度分析工作流。旨在将原始财务数据转化为具备**“逻辑性 (Context)”、“显式化 (Explicit)”**和**“可视性 (Visual)”**的专业投资报告。本协议严格遵循**CIP分析法** (Context-Impact-Price)。

## 核心分析哲学 (Core Philosophy)

- **数据显式 (Data Explicit)**: 每一个观点必须由具体数据支撑，拒绝模糊定性。
- **相对视角 (Relative Perspective)**: 没有对比就没有伤害。必须包含同业对比 (Peers) 和大盘对比 (Benchmark)。
- **逻辑闭环 (Thesis Driven)**: 报告不只是数据的堆砌，必须围绕“投资核心逻辑”展开。

## 核心功能
- 自动获取公司财务数据
- 结构化分析盈利能力、现金流、资产负债状况
- 生成专业分析报告
- 避免常见财务分析误区

## 工具要求
- Python 3.7+
- yfinance 库
- pandas 库
- numpy 库

## 使用方法

### 1. 基础使用
```bash
python3 /home/chengzh/clawd/stock_analyzer_template.py
```

### 2. 分析特定股票
```python
from stock_analyzer_template import StockAnalyzer

analyzer = StockAnalyzer("TICKER")
analyzer.print_formatted_report()
```

### 3. 获取分析数据
```python
from stock_analyzer_template import StockAnalyzer

analyzer = StockAnalyzer("TICKER")
report = analyzer.generate_analysis_report()
# 获取各种分析数据
basic_info = report['basic_info']
profitability = report['profitability']
cash_flow = report['cash_flow']
balance_sheet = report['balance_sheet']
valuation = report['valuation']
```

## 分析框架

### Phase I: Context (环境与基准)

*在此阶段，确定公司在市场中的相对位置。*

- **相对强弱分析 (Relative Strength)**: 
  - 对比标的 vs. 纳斯达克100 (QQQ) / 标普500 (SPY)。
  - 对比标的 vs. 核心竞对 (如 MSFT vs. GOOG vs. AMZN)。
  - **输出**: 计算 Alpha (超额收益) 与 Beta (市场跟随)。
- **宏观归因**: 区分股价波动是源于宏观情绪 (利率、板块轮动) 还是个股基本面。

### Phase II: Fundamentals (深度基本面 "体检")

*在此阶段，进行去伪存真的财务审计。*

#### A. 盈利质量 (Quality of Earnings)

- **核心指标**: 毛利率 (Gross Margin)、净利率 (Net Margin)。
- **分析重点**: 
  - 收入增长 vs. 利润增长的剪刀差（是否存在“增收不增利”？）。
  - 运营杠杆效应分析。

#### B. 现金流与 AI 投入 (Cash Flow & The AI Tax)

- **核心指标**: 
  - **CapEx Intensity (资本开支强度)** = `Capital Expenditure / Revenue`。
    - *阈值警示*: 对于科技巨头，>15% 通常意味着激进的基础设施投入。
  - **FCF Conversion (自由现金流转化率)** = `Free Cash Flow / Net Income`。
- **分析重点**: 识别高额 CapEx 是否在未来 4-8 个季度有明确的 ROI (如 Cloud Revenue 增长)。

#### C. 资产负债表与流动性 (Balance Sheet & Solvency)

- **关键修正 (The Liquidity Check)**:
  - **严禁**只看 "Cash and Cash Equivalents"。
  - **标准公式**: `Net Cash Position = (Cash + Short Term Investments) - Total Debt`。
  - **分析重点**: 区分“真债务危机”与“拥有巨额流动性资产的会计负债”。

### Phase III: Valuation (估值锚点)

- **相对估值**: P/E (TTM & Fwd), EV/EBITDA, EV/Sales (与历史区间及竞对对比)。
- **绝对估值**: **DCF (现金流折现模型)** 交叉验证。
  - 必须输出：`Implied Intrinsic Value` (隐含内在价值) 和 `Margin of Safety` (安全边际)。

## 可视化标准 (Visualization Standards)

*专业报告必须包含以下图表 (Python Generated):*

1.  **Revenue & Margin Combo Chart**: 柱状图(营收) + 折线图(毛利率/净利率)。
2.  **The "AI Tax" Waterfall**: 形象展示 EBITDA 如何被 CapEx 吞噬成为 FCF。
3.  **Relative Performance Line Chart**: 归一化股价走势 (Rebased to 100)，展示 Alpha。
4.  **PE Band**: 股价走势叠加历史平均 P/E 区间。

## 5. 避坑检查清单 (The "Red Pen" Checklist)

*在提交报告前，必须通过以下检查：*

- [ ] **流动性陷阱检查**: 是否漏算了 Short Term Investments？
- [ ] **现金流逻辑检查**: FCF 低于 Net Income 时，是否解释了原因（如 CapEx 激增或 SBC 调整）？
- [ ] **同行对比检查**: 是否回答了“为什么要买它而不是它的对手”？
- [ ] **风险披露检查**: 是否具体化了风险（如“Azure 增速放缓”）而非通用废话（如“宏观经济风险”）？

## 6. Python 工具箱要求 (Tooling Requirements)

*脚本需具备以下模块化功能：*

- `get_financial_data(ticker)`: 自动拉取 Income/Balance/Cashflow 并清洗。
- `calculate_metrics(df)`: 自动计算 CapEx Intensity, Net Cash, FCF Conversion。
- `plot_relative_strength(tickers)`: 生成多股对比图。
- `run_dcf_model(fcf, growth_rate)`: 输出内在价值区间。

## 7. 报告输出模板 (Report Template)

1.  **Investment Thesis**: 一句话核心逻辑。
2.  **Key Risks**: 具体的下行风险。
3.  **Visual Evidence**: 插入 Python 生成的核心图表。
4.  **Deep Dive**: 
    - Profitability
    - Solvency (Net Cash focus)
    - Valuation (DCF + Multiples)
5.  **Conclusion**: 买入/持有/卖出 评级及目标价。

## 关键注意事项

### 1. 避免常见误区
- 仅凭现金等价物判断净现金状况
- 忽视资本开支对现金流的影响
- 仅用单一估值方法

### 2. 深入挖掘指标
- CapEx Intensity = CapEx / Revenue (AI时代的重要指标)
- FCF Conversion Rate = FCF / Net Income
- Debt Structure vs Cash Position

### 3. 数据验证重点
- 区分现金及等价物 vs 短期投资 vs 长期投资
- 正确计算净现金（Net Cash）= 现金及等价物 + 短期投资 - 总债务
- 避免常见的"流动性陷阱"
