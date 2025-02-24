interface ICAFPoolFactory {
    // ACTIONS
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    // IMMUTABLES
    function owner() external view returns (address);

    // EVENTS
    event PoolCreated(
        address indexed creator,
        address indexed tokenA,
        address indexed tokenB,
        uint24 fee,
        address pool
    );
}
