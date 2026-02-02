# 上市公司结构化分析技能包

## 概述
这是一个完整的上市公司分析技能包，包含标准化的分析框架、自动化工具和专业报告模板。

## 文件结构
```
├── SKILL.md              # 技能说明文档
├── README.md             # 本说明文档
├── stock_analyzer_template.py    # 自动化分析工具
└── stock-analysis-methodology.md # 分析方法论文档
```

## 安装依赖
```bash
pip install yfinance pandas numpy
```

## 快速开始
```bash
# 分析微软 (MSFT)
python3 stock_analyzer_template.py

# 或者在Python中使用
from stock_analyzer_template import analyze_stock
analyze_stock("MSFT")  # 替换为任何股票代码
```

## 特性
- **自动化数据获取**: 从Yahoo Finance获取实时财务数据
- **结构化分析**: 按照标准化框架分析各项指标
- **避免常见误区**: 特别关注净现金计算等关键点
- **专业报告**: 生成易于理解的分析报告
- **可扩展性**: 适用于任何上市公司的分析

## 方法论
本技能基于经过验证的分析方法论，包括：
1. 数据获取与验证
2. 盈利能力分析
3. 现金流健康度评估
4. 资产负债结构分析
5. 估值分析
6. 竞争格局对比

## 适用对象
- 金融分析师
- 投资经理
- 研究人员
- 对股票分析感兴趣的学习者